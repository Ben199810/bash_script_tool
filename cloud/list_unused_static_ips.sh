#!/bin/bash
source ../gcloud/switch_project.sh

# 取得所有 internal 的靜態 IP 地址
INTERNAL_IPS=$(gcloud compute addresses list --format="get(address, status)" --filter="TYPE=INTERNAL")

# 取得所有 external 的靜態 IP 地址
EXTERNAL_IPS=$(gcloud compute addresses list --format="get(address, status)" --filter="TYPE=EXTERNAL")

# 列出無使用的靜態 IP 地址
echo -e "${BLUE}Unused internal static IP addresses:${NC}"
while IFS= read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  status=$(echo "$line" | awk '{print $2}')
  
  if [ "$status" == "RESERVED" ]; then
    echo "$ip"
  fi
done <<< "$INTERNAL_IPS"

echo -e "${BLUE}Unused external static IP addresses:${NC}"
while IFS= read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  status=$(echo "$line" | awk '{print $2}')
  
  if [ "$status" == "RESERVED" ]; then
    echo "$ip"
  fi
done <<< "$EXTERNAL_IPS"

echo -e "${GREEN}Done!${NC}"