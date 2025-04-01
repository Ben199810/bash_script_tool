#!/bin/bash
source ../modules/default.sh
source ../modules/switch_gcp_project_enabled.sh

# 取得所有 internal 的靜態 IP 地址
internal_ips=$(gcloud compute addresses list --format="get(address, status)" --filter="TYPE=INTERNAL")

# 取得所有 external 的靜態 IP 地址
external_ips=$(gcloud compute addresses list --format="get(address, status)" --filter="TYPE=EXTERNAL")

# 列出無使用的靜態 IP 地址
echo -e "${BLUE}Unused internal static IP addresses:${NC}"
while IFS= read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  status=$(echo "$line" | awk '{print $2}')
  
  if [ "$status" == "RESERVED" ]; then
    echo "$ip"
  fi
done <<< "$internal_ips"

echo -e "${BLUE}Unused external static IP addresses:${NC}"
while IFS= read -r line; do
  ip=$(echo "$line" | awk '{print $1}')
  status=$(echo "$line" | awk '{print $2}')
  
  if [ "$status" == "RESERVED" ]; then
    echo "$ip"
  fi
done <<< "$external_ips"

echo -e "${GREEN}Done!${NC}"