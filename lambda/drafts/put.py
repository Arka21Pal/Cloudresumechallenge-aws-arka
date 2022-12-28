#!/bin/python

import json
import datetime
import boto3
import config

TABLE_NAME = "visitor-count"

resource = boto3.resource("dynamodb", endpoint_url="http://dynamodb.us-east-1.amazonaws.com", aws_access_key_id=config.aws_access_key_id, aws_secret_access_key=config.aws_secret_access_key, region_name=config.region)

table = resource.Table(TABLE_NAME)

def put_item(TABLE):
    response = TABLE.put_item(
            # Data to be inserted
            Item={
                "Count": 1,
                "Number": 1,
                "Time": str(datetime.datetime.now().time()),
                "Visits": 5
            }
        )

    # https://stackoverflow.com/a/56061155
    print(json.dumps(response, indent=2, default=str))

print("\n")

put_item(table)

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
    print(json.dumps(response["Item"]["Visits"], indent=2, default=str))

show_item(table)

