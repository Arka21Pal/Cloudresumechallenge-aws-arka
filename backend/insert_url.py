#!/bin/python3

"""Python file to get and update value of visitors in DynamoDB table"""

import os
import sys
import traceback
import boto3

def file_operations():
    """Variables and functions defined to interact with DynamoDB table"""

    # Get credentials and values from environment variables defined in Lambda Function
    # Use ".strip()" to remove trailing "\r\n" from the output of "popen()"
#     aws_access_key_id = os.popen('aws configure get aws_access_key_id').read().strip()
#     aws_secret_access_key=os.popen('aws configure get aws_secret_access_key').read().strip()
#     region_name = "us-east-1"

    aws_access_key_id = os.environ.get("aws_access_key_id")
    aws_secret_access_key = os.environ.get("aws_secret_access_key")
    region_name = os.environ.get("region_name")


    # Define session with credentials
    session = boto3.Session(region_name=region_name,
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key)


# -------------


    # Define client
    client = session.client("apigatewayv2")

    # Get API endpoint URL
    api_response = client.get_apis()
    api_endpoint = api_response["Items"][0]["ApiEndpoint"].strip()


# --------------


    # Write API endpoint URL to file
    bucket_name = "url-stack-website-bucket-unique"

    # Define bucket as a resource to read and write to
    bucket = session.resource("s3").Bucket(bucket_name)

    # Define S3Key and local file
    key = "url.js"
    local_file = "/tmp/url.js"
#     local_file = "./url_downloaded.js"

    # Download file
    bucket.download_file(key, local_file)

    # Write to file to upload
    with open(local_file, "w") as api_url_file:
        api_url_file.write('let variable = ' + f'{api_endpoint}')

    # Upload file
    bucket.upload_file(local_file, key)

    # Delete local file
    os.remove(local_file)


def log_exception():
    """Log a stack trace"""
    exc_type, exc_value, exc_traceback = sys.exc_info()
    return repr(traceback.format_exception(exc_type, exc_value, exc_traceback))

# Function which the Lambda function runs

# Variables "event" and "context" are passed by the Lambda Function to this function
# Currently not using the "event" and "context" variables

def lambda_handler(event, context):
    """Lambda handler for the custom resource"""
    try:
        return file_operations()

    except Exception:
        print(log_exception())
        raise
