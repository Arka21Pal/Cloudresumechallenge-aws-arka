#!/usr/bin/python3

"""Python file to get and update value of visitors in DynamoDB table"""

import sys
import traceback
import datetime
import os
import boto3

def table_operations():
    """Variables and functions defined to interact with DynamoDB table"""

    # Get credentials and values from environment variables defined in Lambda Function
    table_name = os.environ.get("table_name")
    aws_access_key_id = os.environ.get("aws_access_key_id")
    aws_secret_access_key = os.environ.get("aws_secret_access_key")
    region_name = os.environ.get("region_name")

    # Define DynamoDB instance as a resource to access it
    resource = boto3.resource("dynamodb",
            endpoint_url="http://dynamodb.us-east-1.amazonaws.com",
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            region_name=region_name)

    # Access specific DynamoDB table
    table_resource = resource.Table(table_name)

    try:
        # Try to get the number of visitors recorded in the table
        visits = table_resource.get_item(Key = {"Count":int(1), "Number":int(1)})["Item"]["Visits"]
    except Exception:
        # If there are no visitors, the function "get_item" will return an error
        # Infer that the value hasn't been initialised, and thus there have been no visitors
        visits = 0

    # Insert values into DynamoDB table
    table_resource.put_item(
            # Data to be inserted
            Item={
                "Count": 1,
                "Number": 1,
                "Time": str(datetime.datetime.now().time()), # Current date and time
                "Visits": visits + 1 # Increment number of visits when API is called
            }
        )

    # Get current number of visits
    current_visits = table_resource.get_item(Key = {"Count":int(1), "Number":int(1)})["Item"]["Visits"]

    # Return response to API via Lambda which the API can parse
    response = {
            "isBase64Encoded": "false",
            "statusCode": 200,
            "body": str(current_visits),
            "headers": {
                "Content-Type" : "application/json",
                "Access-Control-Allow-Headers" : "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods" : "OPTIONS,GET",
                "Access-Control-Allow-Credentials" : "true",
                "Access-Control-Allow-Origin" : "*",
                "X-Requested-With" : "*"
                }
            }

    return response

# Log exceptions
# If using the "AWSLambdaBasicExecutionRole" in the template, can provide permission to upload these logs to Cloudwatch
def log_exception():
    """Log a stack trace"""
    exc_type, exc_value, exc_traceback = sys.exc_info()
    return repr(traceback.format_exception(exc_type, exc_value, exc_traceback))

# Function which the Lambda function runs
# Variables "event" and "context" are passed by the Lambda Function to this function, and must be accepted
# Currently not using the "event" and "context" variables
def lambda_handler(event, context):
    """Lambda handler for the custom resource"""
    try:
        return table_operations()

    except Exception:
        print(log_exception())
        raise
