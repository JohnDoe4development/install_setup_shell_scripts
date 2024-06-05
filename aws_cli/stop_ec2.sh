#!/bin/bash

export AWS_DEFAULT_PROFILE=default
EC2_INSTANCE_NAME="ec2_instance_name"
EC2_REGION="ap-northeast-1"
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=*"${EC2_INSTANCE_NAME}*" \
              "Name=instance-state-name,Values=stopped" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text \
    --region ${EC2_REGION}) | tail -1)
aws ec2 stop-instances --instance-ids ${INSTANCE_ID}
