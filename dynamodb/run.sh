#!/bin/sh

# This file will contain commands to deploy the cloudformation template for s3 and the relevant commands to host a static website.

cloudformationstackactions() {

    # Help function as an overview of the capabilities of the script
    help() {
        printf "\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n" "Here are the various flags supported by the script" \
            "To validate the template, use flag \"-v\"" \
            "To deploy the template, use flag \"-d\"" \
            "To push objects to the existing bucket, use flag \"-p\"" \
            "To check if the bucket contains any objects, use flag \"-c\"" \
            "To empty the bucket, use flag \"-e\"" \
            "To delete the stack (and associated resources), use flag \"-D\"" \
            "To retain the log of the process in a file (mention file as argument after flag), use flag \"-l\""
    }

    # Invoke the "help" function when used without flags and arguments
    if [ $# -eq 0 ]; then
        help
        return
    fi

    # Get the argument specified (the logic is that the word required will be the last argument)
    word="$(for list in "$@"; do : ; done ; printf "%s" "${list}")"

    # Logic for the flags

    validate_template=0     # -v
    deploy_template=0       # -d
    push_to_bucket=0        # -p
    check_bucket=0          # -c
    empty_bucket=0          # -e
    delete_stack=0          # -D
    retain_log=0            # -l

    # In this case, order of commands is very important, as I won't be able to push objects to a bucket without deploying the stack first,
    # Neither will I be able to delete the stack without emptying the bucket first.
    # The arguments are parsed in the ORDER OF THE CASE STATEMENTS/the order in the which opts is defined

    while getopts "vdpeDclh" opts
    do
        case ${opts} in
            v)
                validate_template=1
                ;;
            d)
                deploy_template=1
                ;;
            p)
                push_to_bucket=1
                ;;
            c)
                check_bucket=1
                ;;
            e)
                empty_bucket=1
                ;;
            D)
                delete_stack=1
#                 empty_bucket=1
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

    profile="test-profile"
    region="us-east-1"
    stack="test-stack"
    template="dynamodb.yaml"
    template_body="file://${template}"
    excluded_directory=".git/*"     # Refer to: https://stackoverflow.com/a/39883419
    bucket="${stack}-bucket-unique"
    source_files="../../Web-Resume/"
    target="s3://${bucket}"
    # target=$(printf "%s%s" "s3://" "${bucket}")

    if [ "${validate_template}" = 1 ]; then

        # To validate the template
        aws cloudformation validate-template --region "${region}" --template-body "${template_body}" --profile "${profile}"
    fi

    if [ "${deploy_template}" = 1 ]; then

        # To deploy the stack
        aws cloudformation deploy --template "${template}" --stack-name "${stack}" --region "${region}" --profile "${profile}"
    fi

    if [ "${push_to_bucket}" = 1 ]; then

        # To push to s3 bucket
        aws s3 cp "${source_files}" "${target}" --exclude "${excluded_directory}" --recursive --region "${region}" --profile "${profile}"
    fi

    if [ "${empty_bucket}" = 1 ]; then

        # To empty the s3 bucket
        aws s3 rm s3://"${bucket}" --recursive --region "${region}" --profile "${profile}"
    fi

    if [ "${delete_stack}" = 1 ]; then

        # To delete stack and all resources with it
        aws cloudformation delete-stack --stack-name "${stack}" --region "${region}" --profile "${profile}"
    fi

    if [ "${check_bucket}" = 1 ]; then

        # To check contents of bucket
        aws s3 ls s3://"${bucket}" --recursive --human-readable --summarize --region "${region}" --profile "${profile}"
    fi

    if [  "${retain_log}" = 1 ]; then

        # Write events to file (mentioned as argument)
        aws cloudformation describe-stack-events --stack-name "${stack}" --region "${region}" --profile "${profile}" >> "${word}"
    fi
}

cloudformationstackactions "$@"
