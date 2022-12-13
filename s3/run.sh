#!/bin/sh

# This file will contain commands to deploy the cloudformation template for s3 and the relevant commands to host a static website.

profile="test-profile"
region="us-east-1"
stack="test-stack"
template_body="file://s3_draft.yaml"
template="s3_draft.yaml"
excluded_directory="./.git/*"
bucket="resume-bucket-unique"
source_files="../../resume/"
target="s3://${bucket}"
# target=$(printf "%s%s" "s3://" "${bucket}")

# To validate
aws cloudformation validate-template --region "${region}" --template-body "${template_body}" --profile "${profile}"

# To deploy
# aws cloudformation deploy --template "${template}" --stack-name "${stack}" --region "${region}" --profile "${profile}"


# To push to s3 bucket
# aws s3 cp "${source_files}" "${target}" --exclude "${excluded_directory}" --recursive --region "${region}" --profile "${profile}"

# To empty the s3 bucket
aws s3 rm s3://"${bucket}" --recursive --region "${region}" --profile "${profile}"

# To delete
aws cloudformation delete-stack --stack-name "${stack}" --region "${region}" --profile "${profile}"
