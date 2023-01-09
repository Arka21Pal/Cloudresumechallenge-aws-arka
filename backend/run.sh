#!/bin/sh

# This file will contain commands to deploy the cloudformation template for s3 and the relevant commands to host a static website.

cloudformationstackactions() {

    # Help function as an overview of the capabilities of the script
    help() {
        printf "\n%s\n%s\n%s\n%s\n%s" "Here are the various flags supported by the script" \
            "To validate the template, use flag \"-v\"" \
            "To deploy the template, use flag \"-d\"" \
            "To delete the stack (and associated resources), use flag \"-D\"" \
            "To retain the log of the process in a file (mention file as argument after flag), use flag \"-l\""
    }

    # Invoke the "help" function when used without flags and arguments
    if [ $# -eq 0 ]; then
        help
        return
    fi

    # Logic for the flags

    validate_template=0     # -v
    deploy_template=0       # -d
    delete_stack=0          # -D
    retain_log=0            # -l

    # In this case, order of commands is very important, as I won't be able to push objects to a bucket without deploying the stack first,
    # Neither will I be able to delete the stack without emptying the bucket first.
    # The arguments are parsed in the ORDER OF THE CASE STATEMENTS/the order in the which ${opts} is defined

    while getopts "vdupDlh" opts
    do
        case ${opts} in
            v)
                validate_template=1
                ;;
            d)
                deploy_template=1
                ;;
            D)
                delete_stack=1
                ;;
            l)
                retain_log=1
                ;;
            h)
                help
                return
                ;;
            \?)
                printf "\n%s" "Invalid character. Exiting..."
                return
                ;;
            *)
                printf "\n%s" "Sorry, wrong argument"
                return
                ;;
        esac
    done

# -----------------------
# Basic variables:

    profile="test-profile"
    region_name="us-east-1"
#     stack_name="test-stack"
    stack_name="backend-stack"

# ----------------------
# DynamoDB table

    table_name="visitor-count"

# ---------------------
# Template(s) to run

#     template="api-lambda-dynamodb.yaml"
    template="template.yaml"
    template_body="file://${template}"

# --------------------
# Lambda Functions
# Need environment variables for both

    function_name_1="LambdaFunction"
    function_name_2="InsertLambdaFunction"

# --------------------
# Credentials

    aws_access_key_id="$(aws configure get aws_access_key_id)"
    aws_secret_access_key=$(aws configure get aws_secret_access_key)

# --------------------
# Required IAM capability

    capabilities="CAPABILITY_NAMED_IAM"

# --------------------
# Begin logic


# --------------------
# Validate template
    if [ "${validate_template}" = 1 ]; then

        # To validate the template
        aws cloudformation validate-template --region "${region_name}" --template-body "${template_body}" --profile "${profile}"
    fi

# --------------------
# Deploy Template
# Run helper script "s3run.sh" to deploy bucket with zips of code (for both Lambda Functions)
# Then, deploy "template.yaml"
# Create environment variables for Lambda Functions

    if [ "${deploy_template}" = 1 ]; then

        # Helper script to deploy and prepare CodeBucket
        ./s3run.sh -d

        # To deploy the stack
        aws cloudformation deploy --template "${template}" --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}" --capabilities "${capabilities}"

        # Set environment variables for first Lambda Function (access to DynamoDB)
        aws lambda update-function-configuration --function-name "${function_name_1}" --environment "Variables={table_name='${table_name}', aws_access_key_id='${aws_access_key_id}', aws_secret_access_key='${aws_secret_access_key}', region_name='${region_name}'}" --region "${region_name}" --profile "${profile}"

        # Set environment variables for second Lambda Function (write URL of API to file)
        aws lambda update-function-configuration --function-name "${function_name_2}" --environment "Variables={aws_access_key_id='${aws_access_key_id}', aws_secret_access_key='${aws_secret_access_key}', region_name='${region_name}'}" --region "${region_name}" --profile "${profile}"
    fi

# --------------------
# Delete all resources
# Run helper script to empty CodeBucket, WebsiteBucket and delete storage-stack
# Delete backend-stack

    if [ "${delete_stack}" = 1 ]; then

        # Run helper script to empty buckets and delete storage-stack
        ./s3run.sh -D

        # Delete backend-stack
        aws cloudformation delete-stack --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}"
    fi

    if [  "${retain_log}" = 1 ]; then

        # Write events to file (mentioned as argument)
        aws cloudformation describe-stack-events --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}" >> logfile
    fi
}

cloudformationstackactions "$@"
