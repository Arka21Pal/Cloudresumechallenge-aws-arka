1. Link to version: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/format-version-structure.html
2. Link to official AWS documentation for S3 Cloudoformation template: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html
3. Link to tutorial followed: https://www.varonis.com/blog/create-s3-bucket

To begin with Cloudformation, I needed to first create an user. The user `test-user` was up and I utilised the policy `AdministratorAccess` on it.

I defined the initial `aws profile` using the parameters shown in this tutorial: https://amlanscloud.com/awscliseries1/, and specified output to `yaml`.

This is the command to validate the template:

```
aws cloudformation validate-template --region {region} --template-body {template-body} --profile {profile}
```

Parameters:
- `{region}`: `us-east-1`
- `{template-body}`: `file://{path-to-file}`
- `{profile}`: `name-of-profile`; can be found in `~/.aws/credentials`
