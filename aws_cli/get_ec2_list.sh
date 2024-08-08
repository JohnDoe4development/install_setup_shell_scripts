#!/bin/bash

export AWS_DEFAULT_PROFILE=default
EC2_REGION="ap-northeast-1"
NOV=0
FILTER_VALUE="*"
AWS_OPTION=""

for arg in "$@"; do
  case $arg in
    --nov)
    NOV=1
    shift
    ;;
    --filter)
    shift
    FILTER_VALUE="*$1*"
    shift
    ;;
    *)
    shift
    ;;
  esac
done

# ---

get_ec2_list() {
  EC2_FILTER="Name=tag:Name,Values=$1"
  echo EC2_FILTER: ${EC2_FILTER}
  exit 0
  EC2_QUERY="Reservations[*].Instances[*].{Name:Tags[?Key==\`Name\`] | [0].Value, InstanceId:InstanceId, IpAddress:PublicIpAddress, State:State.Name}"
  aws ec2 describe-instances \
      --query "${EC2_QUERY}" \
      --filters ${EC2_FILTER} \
      --output table \
      --region ${EC2_REGION}
}

main() {
  if [ ${NOV} -eq 1 ]; then
      AWS_OPTION="--no-verify-ssl"
  fi

  get_ec2_list "${FILTER_VALUE}"
}

# ---

main
