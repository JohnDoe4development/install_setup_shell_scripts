#!/bin/bash

EC2_INSTANCE_NAME="ec2_instance_name"
EC2_REGION="ap-northeast-1"
export AWS_DEFAULT_PROFILE=default
EC2_IP_ADDRESS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=*${EC2_INSTANCE_NAME}*" \
                  "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[PublicDnsName]" \
        --output text \
        --region ${EC2_REGION})
echo ${EC2_IP_ADDRESS} | awk -F '.' '{print $1}' | awk -F '-' '{print $2"."$3"."$4"."$5}'
