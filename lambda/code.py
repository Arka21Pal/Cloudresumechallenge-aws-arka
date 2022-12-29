#!/bin/python

import json
import datetime
import os
import boto3

# TABLE_NAME = "visitor-count"
TABLE_NAME = os.environ.get("TABLE_NAME")

aws_access_key_id = os.environ.get("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.environ.get("AWS_SECRET_ACCESS_KEY")
region_name = os.environ.get("REGION_NAME")

resource = boto3.resource("dynamodb", endpoint_url="http://dynamodb.us-east-1.amazonaws.com", aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key, region_name=region_name)

table = resource.Table(TABLE_NAME)

def show_item(TABLE):
    response = TABLE.get_item(
            TableName=TABLE_NAME,
            Key={
                "Count": 1,
                "Number": 1
                }
            )
    # https://stackoverflow.com/a/56061155
#     print(json.dumps(response["Item"], indent=2, default=str))
    visits = int(json.dumps(response["Item"]["Visits"], indent=2, default=str))

    if visits == 0: visits = 1

    return visits

def put_item(TABLE):
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

for i in range(5):
    put_item(table)

print(show_item(table))

# show_item(table)
