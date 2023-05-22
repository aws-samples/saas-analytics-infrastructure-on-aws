import os
import json
import urllib.parse
import boto3
import logging
import re
import datetime as datetime
import pandas as pd
import traceback


def enable_logging():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.INFO)


enable_logging()
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')


def execute(event, context):
    logging.info("Received event: " + json.dumps(event, indent=2))

    try:
        isReplicationEvent = event['Records'][0]['userIdentity']['principalId'].endswith(
            's3-replication')

        if isReplicationEvent:
            logging.info("Ignoring file replication event")
            return "IGNORED_REPLICATION_EVENT"

        # Get the information from the event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(
            event['Records'][0]['s3']['object']['key'], encoding='utf-8')
        createDateTime = event['Records'][0]['eventTime']
        customerId = re.findall(r"input-(.*)-", bucket)[0]
        datasetId = re.findall(r".*-(.*).csv", key)[0]
        size = event['Records'][0]['s3']['object']['size']
        versionId = event['Records'][0]['s3']['object']['versionId']

        logging.info("Getting the S3 file...")
        response = s3.get_object(Bucket=bucket, Key=key)
        file = response['Body']
        df = pd.read_csv(file)
        rows = len(df)
        cols = len(df.columns)

        tableName = os.getenv('DYNAMODB_TABLE_S3_FILE_INPUT')
        table = dynamodb.Table(tableName)

        logging.info(
            "Adding file received event into DynamoDB Table " + tableName)
        response = table.put_item(
            Item={
                # 6 Digit CustomerID + type + 6 Digit DataSetID e.g. "000001|input|000001"
                "CustomerID": customerId,
                # ISO-8601 formatted string + file name e.g. "2022-11-03T19:20:52.612Z|input-2022-11-03-000001-000555.csv"
                "CreatedIndex": createDateTime + "|" + key,
                "Name": key,
                "Bytes": size,
                "Rows": rows,
                "Columns": cols,
                "DatasetID": datasetId,
                "DateReceived": createDateTime,
                "VersionID": versionId
            }
        )

        logging.info("SUCCESS")
        return "SUCCEEDED"
    except Exception as e:
        logging.error(e)
        traceback.print_exc()

    logging.info("FAILED")
    return "FAILED"
