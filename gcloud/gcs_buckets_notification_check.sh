#!/bin/bash
# 查看 bucket notifications List 和 bucket IAM policy

source ../modules/default.sh
source ../modules/switch_gcp_project_enabled.sh

# 使用者輸入 bucket name
read -p "請輸入 bucket name: " bucket_name

# 檢查 bucket name 是否為空
if [ -z $bucket_name ]; then
  echo -e "${RED}bucket name 不得為空。${NC}"
  exit 1
fi

# 顯示當前 bucket notifications List
echo -e "${BLUE}bucket notifications List:${NC}"
gcloud storage buckets notifications list gs://${bucket_name}

# 查看 bucket IAM policy
echo -e "${BLUE}bucket IAM policy:${NC}"
gcloud storage buckets get-iam-policy gs://${bucket_name}