# aws-iam-ec2-svc

A lightweight service that queries the AWS EC2 Instance Metadata service for [Troubleshooting](https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_iam-ec2.html#troubleshoot_iam-ec2_no-keys).

## Getting Started

- Login to AWS CLI
- Run `./scripts/test.ps1 -InstanceProfileId <some_instance_profile_arn> -InstanceImageId <some_image_id>`
- Observe "Green" output, manually checking for any issues as listed on the troubleshooting page.
