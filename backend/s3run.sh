#!/bin/sh

S3bucketactions() {

# --------------------
# Help function

    help() {
        printf "\n%s\n%s\n%s" "Various flags supported by the script" \
            "To deploy stack, use the flag \"-d\"" \
            "To delete stack, use the flag \"-D\""
    }

# --------------------
# Invoke the "help" function when used without flags and arguments

    if [ $# -eq 0 ]; then
        help
        return
    fi

# --------------------
# Variables used for logic when flags are invoked

    deploy=0        # -d
    delete=0        # -D

# --------------------
# Case statement for flags

    while getopts "dDh" opts
    do
        case ${opts} in
            d)
                deploy=1
                ;;
            D)
                delete=1
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


# --------------------
# Stacks

    stack_name_1="storage-stack"
    stack_name_2="backend-stack"

# --------------------
# Buckets

    bucket_1="${stack_name_1}-bucket-unique"
    bucket_2="${stack_name_2}-website-bucket-unique"

# --------------------
# Targets

    target_1="s3://${bucket_1}"
    target_2="s3://${bucket_2}"

# --------------------
# Files

    filename_1="dynamodb"
    code_file_1="${filename_1}.py"
    code_zip_1="${filename_1}.zip"

    filename_2="insert_url"
    code_file_2="${filename_2}.py"
    code_zip_2="${filename_2}.zip"

    filename_3="url"
    code_file_3="${filename_3}.js"

# --------------------
# Common

    region_name="us-east-1"
    profile="test-profile"

# --------------------
# Template for storage-stack

    template="bucket.yaml"


# --------------------
# Begin logic


# --------------------
# Deploy storage-stack
# Push code to CodeBucket
# Push API URL file to WebsiteBucket

    if [ "${deploy}" = 1 ]; then

        # Deploy Template
        aws cloudformation deploy --template "${template}" --stack-name "${stack_name_1}" --region "${region_name}" --profile "${profile}"

        # Create zip of "code_file_1" if it does not exist
        if [ ! -f "${code_zip_1}" ]; then
            zip "${code_zip_1}" "${code_file_1}"
        fi

        # Create zip of "code_file_2" if it does not exist
        if [ ! -f "${code_zip_2}" ]; then
            zip "${code_zip_2}" "${code_file_2}"
        fi

        # Push "code_zip_1" to CodeBucket ("target_1")
        aws s3 cp "${code_zip_1}" "${target_1}" --region "${region_name}" --profile "${profile}"

        # Push "code_zip_2" to CodeBucket ("target_1")
        aws s3 cp "${code_zip_2}" "${target_1}" --region "${region_name}" --profile "${profile}"

        # Push "code_file_3" to WebsiteBucket ("target_2")
        aws s3 cp "${code_file_3}" "${target_2}" --region "${region_name}" --profile "${profile}"

        # Delete zips
        rm "${code_zip_1}"
        rm "${code_zip_2}"
    fi

# --------------------
# Empty CodeBucket, WebsiteBucket
# Delete storage-stack

    if [ "${delete}" = 1 ]; then

        # Empty CodeBucket
        aws s3 rm s3://"${bucket_1}" --recursive --region "${region_name}" --profile "${profile}"

        # Empty WebsiteBucket
        aws s3 rm s3://"${bucket_2}" --recursive --region "${region_name}" --profile "${profile}"

        # Delete storage-stack
        aws cloudformation delete-stack --stack-name "${stack_name_1}" --region "${region_name}" --profile "${profile}"
    fi

}

S3bucketactions "$@"
