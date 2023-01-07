#!/bin/sh

profile="test-profile"
region_name="us-east-1"
stack_name="test-stack"

aws cloudformation delete-stack --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}"
