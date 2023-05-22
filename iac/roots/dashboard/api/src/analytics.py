import os
import json
import boto3
import logging
import traceback
import jwt

from boto3.dynamodb.conditions import Key

APP = os.environ.get('APP')
ENV = os.environ.get('ENV')


def enable_logging():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)
    logging.basicConfig(format='%(asctime)s %(message)s', level=logging.DEBUG)


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
            'body': json.dumps('')
            }


def deep_get(d, keys, default=None):
    """
    Example:
        d = {'meta': {'status': 'OK', 'status_code': 200}}
        deep_get(d, ['meta', 'status_code'])          # => 200
        deep_get(d, ['garbage', 'status_code'])       # => None
        deep_get(d, ['meta', 'garbage'], default='-') # => '-'
    """
    if d is None:
        return default
    if not keys:
        return d
    return deep_get(d.get(keys[0]), keys[1:], default)


def get_analytics(event, context):

    result = ''
    status_code = 500

    access_token = event['headers']['Authorization']
    decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
    cognito_groups = decoded_token["cognito:groups"]
    if cognito_groups and len(cognito_groups) > 0:
        cognito_group = decoded_token["cognito:groups"][0]
        if "admin" in cognito_group:

            analytics_list = list()
            analytics_list.append(Analytics("Analytics1", "It aggregates data across participants and creates average"))
            result = [analytics.to_dict() for analytics in analytics_list]
            status_code = 200

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


class Analytics:
    """
    It represents a analytics.
    """

    def __init__(self,
                 name,
                 description):
        """
        Initializes the Analytics.

        :param name:            The name of the analytics.
        :param description:     The description of the analytics.
        """

        self.name = name
        self.description = description

    def to_dict(self):
        return {
            'name': self.name,
            'description': self.description
        }


def get_customers(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "admin" in cognito_group:

                input_prefix = APP + "-" + ENV + "-customer-input"

                buckets = list_buckets(input_prefix, "-primary")

                customer_list = list()
                for bucket in buckets:
                    customer = Customer(get_customer(bucket))
                    customer_list.append(customer)

                result = [customer.to_dict() for customer in customer_list]

                status_code = 200

    except Exception as error:
        print("Error running get_customers " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


class Customer:
    """
    It represents a customer.
    """

    def __init__(self,
                 id):
        """
        Initializes the customer.

        :param id:            The id of the customer.
        """

        self.id = id

    def to_dict(self):
        return {
            'id': self.id
        }


def get_customer_input_files(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "admin" in cognito_group:

                files = get_files("input")
                file_list = list()
                for file in files:
                    name = file
                    type = file[0:5]
                    date = file[6:16]
                    customer = file[17:23]
                    dataset = file[24:30]
                    file_list.append(CustomerFile(name, type, date, customer, dataset))
                result = [file.to_dict() for file in file_list]

                status_code = 200

    except Exception as error:
        print("Error running get_input_files " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_customer_output_files(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "admin" in cognito_group:

                files = get_files("output")
                file_list = list()
                for file in files:
                    name = file
                    type = file[0:6]
                    date = file[7:17]
                    customer = file[18:24]
                    dataset = file[25:31]
                    file_list.append(CustomerFile(name, type, date, customer, dataset))
                result = [file.to_dict() for file in file_list]

        status_code = 200

    except Exception as error:
        print("Error running get_output_files " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_input_files_for_a_customer(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "customer" in cognito_group:

                customer_id = cognito_group.replace(APP, "").replace(ENV, "").replace("customer", "").replace("group", "").replace("-", "")
                input_file_bucket = APP + "-" + ENV + "-customer-input-" + customer_id + "-primary"
                print("Input File Bucket : " + input_file_bucket)

                files = list_files(input_file_bucket)
                file_list = list()
                for file in files:
                    name = file
                    type = file[0:5]
                    date = file[6:16]
                    customer = file[17:23]
                    dataset = file[24:30]
                    file_list.append(CustomerFile(name, type, date, customer, dataset))
                result = [file.to_dict() for file in file_list]

                status_code = 200

    except Exception as error:
        print("Error running get_input_files_for_a_customer " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_output_files_for_a_customer(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "customer" in cognito_group:

                customer_id = cognito_group.replace(APP, "").replace(ENV, "").replace("customer", "").replace("group", "").replace("-", "")
                output_file_bucket = APP + "-" + ENV + "-customer-output-" + customer_id + "-primary"
                print("Output File Bucket : " + output_file_bucket)

                files = list_files(output_file_bucket)
                file_list = list()
                for file in files:
                    name = file
                    type = file[0:6]
                    date = file[7:17]
                    customer = file[18:24]
                    dataset = file[25:31]
                    file_list.append(CustomerFile(name, type, date, customer, dataset))
                result = [file.to_dict() for file in file_list]

                status_code = 200

    except Exception as error:
        print("Error running get_output_files_for_a_customer " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_file_content(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "customer" in cognito_group:

                customer_id = cognito_group.replace(APP, "").replace(ENV, "").replace("customer", "").replace("group", "").replace("-", "")

                name = deep_get(event, ["queryStringParameters", "name"])
                if name:
                    file_bucket = ""
                    if "input" in name:
                        file_bucket = APP + "-" + ENV + "-customer-input-" + customer_id + "-primary"
                    else:
                        file_bucket = APP + "-" + ENV + "-customer-output-" + customer_id + "-primary"
                    result = read_s3_file_content(file_bucket, name)
                    status_code = 200
                else:
                    result = "Error, incorrect query parameters"
                    status_code = 400
    except Exception as error:
        print("Error running get_output_files_for_a_customer " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def put_file_content(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "customer" in cognito_group:

                customer_id = cognito_group.replace(APP, "").replace(ENV, "").replace("customer", "").replace("group", "").replace("-", "")
                file_bucket = APP + "-" + ENV + "-customer-input-" + customer_id + "-primary"

                body = event["body"]
                print("Body : \n" + body)

                content = ""
                lines = body.splitlines()
                file_name = lines[1].split("filename=")[1].replace("\"", "")
                print("File Name : " + file_name)
                for index in range(3, len(lines)-2):
                    print('NEXT LINE: ' + lines[index])
                    if lines[index].strip() != "":
                        content = content + lines[index] + "\n"
                print("Content : \n" + content)
                write_s3_content(file_bucket, file_name, content)
                status_code = 200
    except Exception as error:
        print("Error running get_output_files_for_a_customer " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_file_events(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "admin" in cognito_group:

                event_list = list()

                dynamodb = boto3.resource('dynamodb', region_name="us-east-1")
                table = dynamodb.Table(APP + "-" + ENV + "-file-events")
                response = table.query(
                    KeyConditionExpression=Key('CustomerID').eq("000001")
                )

                if response['Items']:
                    for item in response['Items']:
                        customer = item["CustomerID"]
                        date = item["DateReceived"][0:19].replace("T", " ")
                        name = item["Name"]
                        dataset = item["DatasetID"]
                        rows = item["Rows"]
                        columns = item["Columns"]
                        bytes = item["Bytes"]
                        event_list.append(FileEvent(customer, date, name, dataset, rows, columns, bytes))

                response = table.query(
                    KeyConditionExpression=Key('CustomerID').eq("000002")
                )

                if response['Items']:
                    for item in response['Items']:
                        customer = item["CustomerID"]
                        date = item["DateReceived"][0:19].replace("T", " ")
                        name = item["Name"]
                        dataset = item["DatasetID"]
                        rows = item["Rows"]
                        columns = item["Columns"]
                        bytes = item["Bytes"]
                        event_list.append(FileEvent(customer, date, name, dataset, rows, columns, bytes))

                result = [event.to_dict() for event in event_list]

                status_code = 200

    except Exception as error:
        print("Error running get_file_events " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_analytics_events(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "admin" in cognito_group:

                date = deep_get(event, ["queryStringParameters", "date"])
                if date:

                    dynamodb = boto3.resource('dynamodb', region_name="us-east-1")
                    table = dynamodb.Table(APP + "-" + ENV + "-analytics-execution")
                    response = table.query(
                        KeyConditionExpression=Key('ExecutionDate').eq(date)
                    )

                    event_list = list()
                    if response['Items']:
                        for item in response['Items']:
                            date = item["ExecutionDate"]
                            time = item["ExecutionDateTime"][0:19].split("T")[1]
                            duration = item["Duration"]
                            files = item["FileCount"]
                            executor = item["RunBy"]
                            event_list.append(AnalyticsEvent(date, time, duration, files, executor))

                    result = [event.to_dict() for event in event_list]

                    status_code = 200
                else:
                    result = "Error, incorrect query parameters"
                    status_code = 400

    except Exception as error:
        print("Error running get_analytics_events " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def update_password(event, context):

    result = ''
    status_code = 500
    try:
        access_token = event['headers']['Authorization']
        decoded_token = jwt.decode(access_token, algorithms=["RS256"], options={"verify_signature": False})
        cognito_groups = decoded_token["cognito:groups"]
        if cognito_groups and len(cognito_groups) > 0:
            cognito_group = decoded_token["cognito:groups"][0]
            if "customer" in cognito_group:

                email = decoded_token["email"]

                input_body = event.get("body")
                if input_body:
                    json_param = json.loads(input_body)
                    pool = json_param["pool"]
                    password = json_param["password"]

                    client = boto3.client('cognito-idp')

                    print("Pool : " + pool)
                    print("User : " + email)
                    print("Password : " + password)
                    client.admin_set_user_password(
                        UserPoolId=pool,
                        Username=email,
                        Password=password,
                        Permanent=True
                    )

                    status_code = 200
                else:
                    result = "Error, incorrect post body"
                    status_code = 400
    except Exception as error:
        print("Error running get_output_files_for_a_customer " + str(error))
        traceback.print_exc()
        result = str(error)

    response = {
        "statusCode": status_code,
        'headers': cors_headers(),
        "body": json.dumps(result, indent=2, sort_keys=True, default=str)
    }

    return response


def get_files(filter):
    input_prefix = APP + "-" + ENV + "-customer-" + filter

    buckets = list_buckets(input_prefix, "-primary")

    file_list = list()
    for bucket in buckets:
        print("Bucket: " + bucket)
        files = list_files(bucket)
        for file in files:
            print("File: " + file)
            if file.startswith(filter):
                file_list.append(file)

    return file_list


class CustomerFile:
    """
    It represents a customer file.
    """

    def __init__(self,
                 name,
                 type,
                 date,
                 customer,
                 dataset):
        """
        Initializes the customer.

        :param name:        The name of the customer file.
        :param type:        The type of the customer file.
        :param date:        The date of the customer file.
        :param customer:    The customer id of the customer file.
        :param dataset:     The dataset id of the customer file.
        """

        self.name = name
        self.type = type
        self.date = date
        self.customer = customer
        self.dataset = dataset

    def to_dict(self):
        return {
            'name': self.name,
            'type': self.type,
            'date': self.date,
            'customer': self.customer,
            'dataset': self.dataset
        }


class FileEvent:
    """
    It represents a file event.
    """

    def __init__(self,
                 customer,
                 date,
                 name,
                 dataset,
                 rows,
                 columns,
                 bytes):
        """
        Initializes the customer.

        :param name:    The name of the customer.
        """

        self.customer = customer
        self.date = date
        self.name = name
        self.dataset = dataset
        self.rows = rows
        self.columns = columns
        self.bytes = bytes

    def to_dict(self):
        return {
            'customer': self.customer,
            'date': self.date,
            'name': self.name,
            'dataset': self.dataset,
            'rows': self.rows,
            'columns': self.columns,
            'bytes': self.bytes
        }


class AnalyticsEvent:
    """
    It represents an analytics event.
    """

    def __init__(self,
                 date,
                 time,
                 duration,
                 files,
                 executor):
        """
        Initializes the analytics event.

        :param date:            The date of the event.
        :param time:            The time of the event.
        :param duration:        The duration of the event.
        :param files:           The files used in the event.
        :param executor:        The person who executed the event.
        """

        self.date = date
        self.time = time
        self.duration = duration
        self.files = files
        self.executor = executor

    def to_dict(self):
        return {
            'date': self.date,
            'time': self.time,
            'duration': self.duration,
            'files': self.files,
            'executor': self.executor
        }


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
        print("Error listing bucket: prefix = " + prefix + " suffix = " + suffix + " : " + str(error))
        traceback.print_exc()


def read_s3_file_content(bucket, file):

    try:
        s3_client = boto3.client("s3")
        response = s3_client.get_object(Bucket=bucket, Key=file)
        return response.get("Body").read().decode('utf-8')

    except Exception as error:
        print("Error reading s3 file: bucket = " + bucket + " key = " + file + " : " + str(error))
        traceback.print_exc()


def write_s3_content(bucket, key, content):

    s3_client = boto3.client("s3")

    response = s3_client.put_object(Bucket=bucket, Key=key, Body=content)

    status = response.get("ResponseMetadata", {}).get("HTTPStatusCode")

    if status == 200:
        print(f"Successful S3 put_object response. Status - {status}")
    else:
        print(f"Unsuccessful S3 put_object response. Status - {status}")
        raise ValueError(f"Unsuccessful S3 put_object response. Status - {status}")


def get_customer(bucket):
    customer = bucket.replace(APP + "-" + ENV + "-customer-input-", "")
    customer = customer.replace("-primary", "")
    return customer


def list_files(bucket):
    files = list()
    try:

        s3_client = boto3.client("s3")
        response = s3_client.list_objects(Bucket=bucket)
        for entry in response["Contents"]:
            files.append(entry["Key"])

    except Exception as error:
        print("Error listing files in s3 bucket : " + bucket + " : " + str(error))
        traceback.print_exc()

    return files


if __name__ == "__main__":

    # output = get_analytics(dict(), dict())
    # print(output)

    # output = get_customers(dict(), dict())
    # print(output)

    # output = get_customer_input_files(dict(), dict())
    # print(output)

    output = read_s3_file_content(s3_bucket, "output-2022-09-23-000001-000001.csv")
    print(output)