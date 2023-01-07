#!/bin/python

import json
import datetime
import boto3
import config

TABLE_NAME = "visitor-count"

aws_access_key_id = "AKIAX7ATM45X7724GN6Z"
aws_secret_access_key = "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"
region_name = "us-east-1"

resource = boto3.resource("dynamodb", endpoint_url="http://dynamodb.us-east-1.amazonaws.com", aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key, region_name=region_name)

table = resource.Table(TABLE_NAME)

for i in range(5):

    def put_item(TABLE):
        response = TABLE.put_item(
                # Data to be inserted
                Item={
                    "Count": 1,
                    "Number": 1,
                    "Time": str(datetime.datetime.now().time()),
                    "Visits": i
                }
            )

        # https://stackoverflow.com/a/56061155
        print(json.dumps(response, indent=2, default=str))

    def show_item(TABLE):
        response = TABLE.get_item(
                TableName=TABLE_NAME,
                Key={
                    "Count": 1,
                    "Number": 1
                    }
                )

        # https://stackoverflow.com/a/56061155
        print(json.dumps(response["Item"], indent=2, default=str))
#         print(json.dumps(response["Item"]["Visits"], indent=2, default=str))

    put_item(table)
    show_item(table)