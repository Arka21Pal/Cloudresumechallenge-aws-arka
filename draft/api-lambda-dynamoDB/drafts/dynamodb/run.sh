#!/bin/sh

profile="test-profile"
region_name="us-east-1"
stack_name="test-stack"
# table_name="visitor-count"

template="dynamoDB.yaml"

aws cloudformation deploy --template "${template}" --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}"
