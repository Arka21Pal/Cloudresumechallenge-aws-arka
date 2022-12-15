1. Link to version: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/format-version-structure.html
2. Link to official AWS documentation for S3 Cloudoformation template: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html
3. Link to tutorial followed: https://www.varonis.com/blog/create-s3-bucket

To begin with Cloudformation, I needed to first create an user. The user `test-user` was up and I utilised the policy `AdministratorAccess` on it.

I defined the initial `aws profile` using the parameters shown in this tutorial: https://amlanscloud.com/awscliseries1/, and specified output to `yaml`.

This is the command to validate the template:

```
aws cloudformation validate-template --region {region} --template-body {template_body} --profile {profile}
```

Parameters:
- `{region}`: `us-east-1`
- `{template_body}`: `file://{path-to-file}`
- `{profile}`: `name-of-profile`; can be found in `~/.aws/credentials`

To deploy [link](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-deploy.html):

```
aws cloudformation deploy --template {template} --stack-name {stack} --region {region} --profile {profile}
```

To delete stack and all resources associated with the stack [link](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-cli-deleting-stack.html):

```
aws cloudformation delete-stack --stack-name {stack} --region {region} --profile {profile}
```

To push to `s3`:

```
aws s3 cp {source_files} {target} --exclude {excluded_directory} {--options} --region {region} --profile {profile}
```

`{--options}`: `--recursive` is for uploading a directory.

For example: `aws s3 cp ../../resume/ s3://resume-bucket-unique --recursive --exclude ".git/*" --region us-east-1 --profile test-profile`

To list objects in an `s3` bucket [link](https://bobbyhadz.com/blog/aws-cli-list-all-files-in-bucket#list-all-files-in-an-s3-bucket-with-aws-cli):

```
aws s3 ls s3://${bucket} --recursive --human-readable --summarize --region ${region} --profile ${profile}
```

Ideally, you should empty a bucket before deleting it, the command being:

```
aws s3 rm s3://{bucket} --recursive --region {region} --profile {profile}
```

`{bucket}`: "name-of-bucket"

One can also delete just a specific directory by specifying `{s3://bucket/directory/}`. Removing the `--recursive` option only deletes a specific file if specified correctly.

But if you don't want to run the extra command, the following command will forcibly delete the bucket and all objects in it. This ***does not*** include versioned buckets.

```
aws s3 rb s3://{bucket-name} --force --region {region} --profile {profile}
```

For versioned buckets, the current best approach would be to use `Python` and `boto3`, [link](https://stackoverflow.com/questions/29809105/how-do-i-delete-a-versioned-bucket-in-aws-s3-using-the-cli)


For public read and creating a static website, resources:
- https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-2
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-policy.html
- https://awstip.com/deploy-a-static-website-to-aws-s3-in-seconds-with-cloudformation-ac489158054f
- https://www.coletiv.com/blog/how-to-use-aws-cloud-formation-to-setup-the-infrastructure-for-a-static-website/
- https://medium.com/swlh/aws-website-hosting-with-cloudformation-guide-36cac151d1af#98e9


---


Sometimes, because AWS calls contain timestamps, the command sent from a particular machine might fail because the time of the machine might be a few minutes off of what AWS was expecting. In such cases, a [good solution](https://stackoverflow.com/questions/44017410/signature-expired-is-now-earlier-than-error-invalidsignatureexception) would be to:

```
sudo apt install ntp ntpdate
sudo service ntp stop

sudo ntpdate pool.ntp.org
or
sudo ntpdate ntp.ubuntu.com

 sudo service ntp start
```
