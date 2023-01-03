#!/bin/python

"""Python file to get and update value of visitors in DynamoDB table"""

import sys
import traceback
import json
import datetime
import os
import boto3


def log_exception():
    """Log a stack trace"""
    exc_type, exc_value, exc_traceback = sys.exc_info()
    print(repr(traceback.format_exception(exc_type, exc_value, exc_traceback)))


# table_name = "visitor-count"
table_name = os.environ.get("table_name")

aws_access_key_id = os.environ.get("aws_access_key_id")
aws_secret_access_key = os.environ.get("aws_secret_access_key")
region_name = os.environ.get("region_name")

resource = boto3.resource("dynamodb",
        endpoint_url="http://dynamodb.us-east-1.amazonaws.com",
        aws_access_key_id=aws_access_key_id,
        aws_secret_access_key=aws_secret_access_key,
        region_name=region_name)

TABLE = resource.Table(table_name)

def show_item(TABLE):
    """Function to get items and return output from DynamoDB table"""
    response = TABLE.get_item(
            TableName=table_name,
            Key={
                "Count": 1,
                "Number": 1
                }
            )
    # https://stackoverflow.com/a/56061155
#     print(json.dumps(response["Item"], indent=2, default=str))
    visits = int(json.dumps(response["Item"]["Visits"], indent=2, default=str))

    if visits == 0:
        visits = 1

    return visits

def put_item(TABLE):
    """Function to put item/update item in DynamoDB table"""
    response = TABLE.put_item(
            # Data to be inserted
            Item={
                "Count": 1,
                "Number": 1,
                "Time": str(datetime.datetime.now().time()),
                "Visits": int(show_item(TABLE)) + 1
            }
        )

    # https://stackoverflow.com/a/56061155
    return json.dumps(response, indent=2, default=str)

def lambda_handler(TABLE):
    """Lambda handler for the custom resource"""
    try:
        i = 5
        while i:
            put_item(TABLE)
            i -= 1

        print(show_item(TABLE))

    except Exception:
        log_exception()
        raise
