- Use a file to keep secrets for the shell script used to invoke aws cli.
- Pass these variables as environment variables to lambda to use in python code.
- Write python script for DynamoDB to fetch results.

- Define four variables for the shell script to pass as environment variables.
- `aws configure get aws_access_key_id`
- `aws configure get aws_secret_access_key`





































- First, we need an `s3` bucket to store the code for the Lambda function.
- For which, the lambda function needs to have adequate access to the `s3` bucket.

JSON example:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:AbortMultipartUpload"
            ],
            "Resource": [
                "arn:aws:s3:::YOUR_BUCKET",
                "arn:aws:s3:::YOUR_BUCKET/*"
            ]
        }
    ]
}
```

- Since the lambda function just needs to read the file from the bucket, we can suffice with just read permissions.
- Then, deploy lambda function with code to update `DynamoDB` table.
