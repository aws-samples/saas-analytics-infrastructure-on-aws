import os

import jwt
import pandas as pd
import datetime as dt
from datetime import datetime, timezone
import io
import json
import boto3
import logging
import traceback
import time

APP = os.environ.get('APP')
ENV = os.environ.get('ENV')
SUFFIX = "primary"


def enable_logging():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


start_time = 0
enable_logging()


def cors_headers():
    return {
        'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,HEAD,PUT,DELETE,PATCH'
    }


def options(event, context):
    logging.debug("HTTP OPTIONS: Returning CORS Headers")
    return {'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET,HEAD,PUT,DELETE,PATCH'
            },
            'body': json.dumps('Hello from CLS UI Service!')
            }


def execute(event, context):
    global start_time
    start_time = time.time()
    logging.info("Received event: " + json.dumps(event, indent=2))

    result = ''
    status_code = 500
    try:
        if is_run_analytics(event):

            metadata = {
                'fileCount': 0
            }

            p_date = dt.date(2022, 9, 23)
            date = p_date.strftime("%Y-%m-%d")

            # in practice, we'll also want an insert time
            df_in_should_be_db = pd.DataFrame(
                columns=['Date', 'ClientID', 'Tag1', 'Tag2', 'Value', 'AggKey'])
            df_agg_should_be_db = pd.DataFrame(
                columns=['Date', 'AggKey', 'Average', 'nbInput'])

            df_in_should_be_db = get_input_files(
                metadata, date, "000001", df_in_should_be_db)
            df_agg_should_be_db = process_data(
                p_date, df_in_should_be_db, df_agg_should_be_db)
            generate_output_files(p_date, "000001",
                                    df_in_should_be_db, df_agg_should_be_db)

            write_analytics_metadata(metadata["fileCount"], event)

            status_code = 200

    except Exception as error:
        print("Error executing analytics: " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response

def is_run_analytics(event) -> bool:
    """
    Return True if the request came from an admin or from EventBridge.

    :param event: The execute lambda event
    :return: True if the request came from an admin or from EventBridge
    """
    if 'source' in event and event['source'] == 'aws.events':
        return True
    
    access_token = event['headers']['Authorization']
    decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
    cognito_groups = decoded_token["cognito:groups"]
    if cognito_groups and len(cognito_groups) > 0:
        cognito_group = decoded_token["cognito:groups"][0]
        if "admin" in cognito_group:
            return True

    return False

def write_analytics_metadata(fileCount: int, event) -> None:
    """
    Write metadata about the analytics process.

    :param fileCount: The number of files processed
    :param event: The lambda event
    :return: nothing
    """

    if "source" in event:
        caller = event['source']
        executionID = event['id']
    elif "authorizer" in event['requestContext']:
        caller = event['requestContext']['authorizer']['claims']['email']
        executionID = event['requestContext']['requestId']
    else:
        caller = event['requestContext']['identity']['caller']
        executionID = event['requestContext']['requestId']

    dynamodb = boto3.resource('dynamodb')
    tableName = "{app}-{env}-analytics-execution".format(
        app=APP, env=ENV)
    table = dynamodb.Table(tableName)
    table.put_item(
        Item={
            "ExecutionDate": str(datetime.utcnow().date()),
            "ExecutionId": executionID,
            "FileCount": fileCount,
            "ExecutionDateTime": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "Duration": "%s seconds" % round(time.time() - start_time, 2),
            "RunBy": caller
        }
    )


def get_input_files(metadata, date, dataset, df_in_should_be_db: pd.DataFrame) -> pd.DataFrame:
    """
    Gets the input files from path_in for the right date for all clients, and puts them in df_in_should_be_db.

    :param metadata: Dictionary to record metadata about the input files
    :param p_date: The date to get input files, date is part of the generated path
    :param path_in: The path with the folder where the files are
    :param df_in_should_be_db: Ideally we'd have a DB to store input data,  instead passing around a DataFrame
    :return: the updated pseudo_database df_in_should_be_in_db
    """

    input_prefix = APP + "-" + ENV + "-customer-input"

    buckets = list_buckets(input_prefix, SUFFIX)
    for bucket in buckets:
        customer = get_customer(bucket)
        file = read_s3_file(bucket, date, customer, dataset)
        df = pd.read_csv(file, dtype={
                         'Date': str, 'ClientID': str, 'Tag1': str, 'Tag2': str, 'Value': float})
        metadata["fileCount"] = metadata["fileCount"] + 1

        # For now just ignoring badly formatted entries
        if set(df.columns) == set({'Date', 'ClientID', 'Tag1', 'Tag2', 'Value'}):
            df['Date'] = pd.to_datetime(df['Date']).dt.date
            df['AggKey'] = df['Tag1'] + df['Tag2']
            df_in_should_be_db = df_in_should_be_db.append(
                df, ignore_index=True)

    return df_in_should_be_db


def process_data(p_date: datetime.date, df_in_should_be_db: pd.DataFrame, df_agg_should_be_db: pd.DataFrame) -> pd.DataFrame:
    """
    Process the data and put results in df_agg_should_be_db.  The processing is to take the value per unique keys, and take the mean as a "secret sauce".

    :param p_date: The date to operate the aggregation
    :param df_in_should_be_db: Ideally we'd have a DB to store input data, instead passing around a DataFrame
    :param df_agg_should_be_db: Ideally we'd have a DB to store aggregated data, instead passing around a DataFrame
    :return: the updated pseudo database df_agg_should_be_db
    """
    today_in_df = df_in_should_be_db[df_in_should_be_db['Date'] == p_date]
    # Will vectorize later, keeping like this for readability
    for product, product_today_in_df in today_in_df.groupby('AggKey'):

        p_average = product_today_in_df['Value'].mean()
        nb_client_input = len(product_today_in_df)
        nb_unique_client_input = len(product_today_in_df['ClientID'].unique())
        # For now  dropping product with double entry by a participant
        if (nb_client_input == nb_unique_client_input):
            new_entry = {'Date': p_date,
                         'AggKey': product,
                         'Average': p_average,
                         'nbInput': nb_client_input}
            df_agg_should_be_db = df_agg_should_be_db.append(
                new_entry, ignore_index=True)

    return df_agg_should_be_db


def generate_output_files(p_date: datetime.date, dataset: str, df_in_should_be_db: pd.DataFrame, df_agg_should_be_db: pd.DataFrame):
    """
    Generates the output files to be sent to clients

    :param p_date: The date to generate output files, date is part of the generated path
    :param path_out: The path where to drop the output files
    :param df_in_should_be_db: Ideally we'd have a DB to store input data, instead sending a DataFrame where we store data
    :param df_agg_should_be_db: Ideally we'd have a DB to store aggregated data, instead sending a DataFrame where we store data
    :return: returns nothing
    """
    today_in_df = df_in_should_be_db[df_in_should_be_db['Date'] == p_date]
    today_agg_df = df_agg_should_be_db[df_agg_should_be_db['Date'] == p_date]

    # Will vectorize later, keeping like this for readability
    for clientID, client_today_in_df in today_in_df.groupby('ClientID'):
        client_today_out = pd.DataFrame(columns={
                                        'Date': str, 'Tag1': str, 'Tag2': str, 'Value': float, 'YourId': int, 'YourValue': float})
        for product, client_product in client_today_in_df.groupby('AggKey'):
            common_product = today_agg_df[today_agg_df['AggKey'] == product]
            if (common_product['nbInput'].values.item() > 1):
                new_entry = {'Date': p_date.strftime('%Y%m%d'),
                             'Tag1': client_product['Tag1'].values.item(),
                             'Tag2': client_product['Tag1'].values.item(),
                             'Value': common_product['Average'].values.item(),
                             'YourId': clientID,
                             'YourValue': client_product['Value'].values.item()}
                client_today_out = client_today_out.append(
                    new_entry, ignore_index=True)
        with io.StringIO() as csv_buffer:
            client_today_out.to_csv(csv_buffer, index=False)
            bucket = APP + "-" + ENV + "-customer-output-" + clientID + "-primary"
            key = "output-" + \
                p_date.strftime("%Y-%m-%d") + "-" + \
                clientID + "-" + dataset + ".csv"
            write_s3_file(bucket, key, csv_buffer)


def list_buckets(prefix, suffix):
    try:
        s3_client = boto3.client("s3")

        response = s3_client.list_buckets()

        buckets = list()
        for bucket in response['Buckets']:
            name = bucket["Name"]
            if name.startswith(prefix) and name.endswith(suffix):
                buckets.append(name)

        return buckets

    except Exception as error:
        print("Error listing bucket: prefix = " + prefix +
              " suffix = " + suffix + " : " + str(error))
        traceback.print_exc()


def read_s3_file(bucket, date, customer, dataset):

    try:
        key = "input-" + date + "-" + customer + "-" + dataset + ".csv"
        s3_client = boto3.client("s3")
        response = s3_client.get_object(Bucket=bucket, Key=key)
        return response.get("Body")

    except Exception as error:
        print("Error reading s3 file: bucket = " +
              bucket + " key = " + key + " : " + str(error))
        traceback.print_exc()


def write_s3_file(bucket, key, content):

    try:
        s3_client = boto3.client("s3")

        response = s3_client.put_object(
            Bucket=bucket, Key=key, Body=content.getvalue())

        status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")

        if status == 200:
            print(f"Successful S3 put_object response. Status - {status}")
        else:
            print(f"Unsuccessful S3 put_object response. Status - {status}")
            raise ValueError(
                f"Unsuccessful S3 put_object response. Status - {status}")

    except Exception as error:
        print("Error writing s3 file: bucket = " +
              bucket + " key = " + key + " : " + str(error))
        traceback.print_exc()


def get_customer(bucket):
    customer = bucket.replace(APP + "-" + ENV + "-customer-input-", "")
    customer = customer.replace("-primary", "")
    return customer


if __name__ == "__main__":
    execute(dict(), dict())
