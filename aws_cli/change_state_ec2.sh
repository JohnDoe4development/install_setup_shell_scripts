#!/bin/bash

export AWS_DEFAULT_PROFILE=default
EC2_INSTANCE_NAME="ec2_instance_name"
EC2_REGION="ap-northeast-1"
AWS_OPTION=""
STATE=0
NOV=0
ACTION="start"
CURRENT_STATE="stopped"

for arg in "$@"; do
  case $arg in
    --nov)
    NOV=1
    shift
    ;;
    --stop)
    DEBUG_MODE=1
    STATE=0
    shift
    ;;
    --start)
    STATE=1
    shift
    ;;
    --state)
    shift
    STATE=$1
    shift
    ;;
    *)
    echo "無効な引数です."
    echo "中止します."
    exit 1
    ;;
  esac
done

# ---

get_instance_id() {
  EC2_FILTER="Name=tag:Name,Values=*$1*"
  EC2_QUERY="Reservations[*].Instances[*].InstanceId"
  INSTANCE_ID=$(aws ec2 describe-instances \
      --filters ${EC2_FILTER} \
                "Name=instance-state-name,Values=$2" \
      --query ${EC2_QUERY} \
      --output text \
      --region ${EC2_REGION} | tail -1)
}

main() {
  if [ ${NOV} -eq 1 ]; then
      AWS_OPTION="--no-verify-ssl"
  fi

  if [ ${STATE} -eq 1 ]; then
      ACTION="start"
      CURRENT_STATE="stopped"
  elif [ ${STATE} -eq 0 ]; then
      ACTION="stop"
      CURRENT_STATE="running"
  fi

  get_instance_id ${EC2_INSTANCE_NAME} ${CURRENT_STATE}
  aws ${AWS_OPTION} ec2 ${ACTION}-instances --instance-ids ${INSTANCE_ID}
}

# ---

main
