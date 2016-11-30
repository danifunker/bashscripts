#!/bin/bash
#This script can be used as a lightweight bootstrap which downloads additional
#instructions from your AWS S3 bucket. Bucket must be in the same region as EC2
bucket="YourBucketName"
aws s3 cp s3://$bucket/bootstrap.sh ~
chmod +x ~/bootstrap.sh
~/bootstrap.sh
