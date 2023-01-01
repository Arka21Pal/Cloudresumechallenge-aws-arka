#!/bin/sh

# Create s3 bucket for lambda code

S3bucketactionsLambda() {

    help() {
        printf "\n%s\n%s\n%s" "Various flags supported by the script" \
            "To deploy the bucket, use the flag \"-p\"" \
            "To empty the bucket, use the flag \"-e\""
    }

    # Invoke the "help" function when used without flags and arguments
    if [ $# -eq 0 ]; then
        help
        return
    fi

    deploy=0        # -d
    empty=0         # -e

    while getopts "deh" opts
    do
        case ${opts} in
            d)
                deploy=1
                ;;
            e)
                empty=1
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

    stack="code-bucket-stack"
    bucket="${stack}-bucket-unique"
    filename="code"
    code_file="${filename}.py"
    code_zip="${filename}.zip"
    region_name="us-east-1"
    profile="test-profile"
    target="s3://${bucket}"
    template="bucket.yaml"


    if [ "${deploy}" = 1 ]; then

        # Deploy Template
        aws cloudformation deploy --template "${template}" --stack-name "${stack}" --region "${region_name}" --profile "${profile}"

        # Create zip if it does not exist
        if [ ! -f "${code_zip}" ]; then
            zip "${code_zip}" "${code_file}"
        fi

        # Push to bucket
        aws s3 cp "${code_zip}" "${target}" --region "${region_name}" --profile "${profile}"

    fi

    if [ "${empty}" = 1 ]; then

        # Empty bucket
        aws s3 rm s3://"${bucket}" --recursive --region "${region_name}" --profile "${profile}"

        # To delete stack and all resources with it
        aws cloudformation delete-stack --stack-name "${stack}" --region "${region_name}" --profile "${profile}"
    fi

}

S3bucketactionsLambda "$@"
