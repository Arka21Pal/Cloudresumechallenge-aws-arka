#!/usr/bin/python3

"""Python file to get and update value of visitors in DynamoDB table"""

import sys
import traceback
import json
import datetime
# import os
import boto3

def table_operations():
    """Variables and functions defined to interact with DynamoDB table"""

    table_name = "visitor-count"
    aws_access_key_id = "AKIAX7ATM45X7724GN6Z"
    aws_secret_access_key = "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"
    region_name = "us-east-1"

    resource = boto3.resource("dynamodb",
            endpoint_url="http://dynamodb.us-east-1.amazonaws.com",
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            region_name=region_name)

    table_resource = resource.Table(table_name)

    for i in range(5):
        table_resource.put_item(
                # Data to be inserted
                Item={
                    "Count": 1,
                    "Number": 1,
                    "Time": str(datetime.datetime.now().time()),
                    "Visits": i
                }
            )

#         print("\n")
#         print(table_resource.get_item(Key = {"Count":int(1), "Number":int(1)}))
    data = table_resource.get_item(Key = {"Count":int(1), "Number":int(1)})["Item"]["Visits"]
    print(data)












def log_exception():
    """Log a stack trace"""
    exc_type, exc_value, exc_traceback = sys.exc_info()
    return repr(traceback.format_exception(exc_type, exc_value, exc_traceback))


try:
    table_operations()
except Exception:
    print(log_exception())






















































































#     def show_item(resource_name):
#         """Function to get items and return output from DynamoDB table"""
#         response = resource_name.get_item(
#                 TableName=table_name,
#                 Key={
#                     "Count": 1,
#                     "Number": 1
#                     }
#                 )

        # https://stackoverflow.com/a/56061155
#         print(json.dumps(response["Item"], indent=2, default=str))
#         visits = int(json.dumps(response["Item"]["Visits"], default=str))
#         visits = json.dumps(response)

#         if visits == 0:
#             visits = 1

#         return visits

#     def put_item(resource_name):
#         """Function to put item/update item in DynamoDB table"""
#         response = resource_name.put_item(
#                 # Data to be inserted
#                 Item={
#                     "Count": 1,
#                     "Number": 1,
#                     "Time": str(datetime.datetime.now().time()),
#                     "Visits": int(show_item(resource_name)) + 1
#                 }
#             )
#
#         # https://stackoverflow.com/a/56061155
#         return json.dumps(response, default=str)
#
#     show_item(table_resource)
#
#     i = 5
#     while i:
#         put_item(table_resource)
#         i -= 1
#
#     show_item(table_resource)




# def lambda_handler(event, context):
#     """Lambda handler for the custom resource"""
#     try:
#         table_operations()
#
#         print("\n")
#         print(event)
#         print("\n")
#         print(context)
#
#     except Exception:
#         print(log_exception())
#         raise
