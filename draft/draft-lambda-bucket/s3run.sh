#!/bin/sh

# Create s3 bucket for lambda code

S3bucketactions() {

    help() {
        printf "\n%s\n%s\n%s" "Various flags supported by the script" \
            "To deploy the bucket, use the flag \"-d\"" \
            "To delete the bucket, use the flag \"-D\""
    }

    # Invoke the "help" function when used without flags and arguments
    if [ $# -eq 0 ]; then
        help
        return
    fi

    # Variables used for logic when flags are invoked
    deploy=0        # -d
    delete=0        # -D

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

    stack_name="storage-stack"
    bucket="${stack_name}-bucket-unique"
    filename="insert_url"
    code_file="${filename}.py"
    code_zip="${filename}.zip"
    region_name="us-east-1"
    profile="test-profile"
    target="s3://${bucket}"
    template="bucket.yaml"


    if [ "${deploy}" = 1 ]; then

        # Deploy Template
        aws cloudformation deploy --template "${template}" --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}"

        # Create zip if it does not exist
        if [ ! -f "${code_zip}" ]; then
            zip "${code_zip}" "${code_file}"
        fi

        # Push to bucket
        aws s3 cp "${code_zip}" "${target}" --region "${region_name}" --profile "${profile}"
#         aws s3 cp "${code_file}" "${target}" --region "${region_name}" --profile "${profile}"

        # Delete zip
        rm "${code_zip}"
    fi

    if [ "${delete}" = 1 ]; then

        # Empty bucket
        aws s3 rm s3://"${bucket}" --recursive --region "${region_name}" --profile "${profile}"

        # To delete stack and all resources with it
        aws cloudformation delete-stack --stack-name "${stack_name}" --region "${region_name}" --profile "${profile}"
    fi

}

S3bucketactions "$@"
