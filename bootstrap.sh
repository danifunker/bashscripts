#!/bin/bash
#bucket must be in the same region as the EC2 instance. Copy this file to the bucket
bucket=“YourBucketName”
yum install httpd -y
yum update -y
aws s3 cp s3://$bucket/index.html /var/www/html
service httpd start
chkconfig httpd on
