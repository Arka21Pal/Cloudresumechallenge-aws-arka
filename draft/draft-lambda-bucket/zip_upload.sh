#!/bin/sh


filename="insert_url"
code_file="${filename}.py"
code_zip="${filename}.zip"
stack_name="storage-stack"
bucket="${stack_name}-bucket-unique"
target="s3://${bucket}"
profile="test-profile"
region_name="us-east-1"


# Create zip if it does not exist
if [ ! -f "${code_zip}" ]; then
    zip "${code_zip}" "${code_file}"
fi

# Push to bucket
aws s3 cp "${code_zip}" "${target}" --region "${region_name}" --profile "${profile}"
#         aws s3 cp "${code_file}" "${target}" --region "${region_name}" --profile "${profile}"

# Delete zip
rm "${code_zip}"
