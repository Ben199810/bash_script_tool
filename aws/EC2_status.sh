#!/bin/bash
source ../modules/default.sh

get_instances() {
  local region=$(aws configure get region)

  instances=$(aws ec2 describe-instances --region "$region" \
    --filter "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value | [0], InstanceId, InstanceType, PrivateIpAddress, Placement.AvailabilityZone]" \
    --output text)

  echo -e "${GREEN}EC2 實例列表：${NC}"
  if [ -z "$instances" ]; then
    echo -e "${YELLOW}沒有運行中的 EC2 實例。${NC}"
  else
    echo -e "$instances"
  fi
}

get_instances