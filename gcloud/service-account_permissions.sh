#!/bin/bash
source ../gcloud/switch_project.sh

# 列出所有 service accounts 並使用 fzf 選擇
service_account=$(gcloud iam service-accounts list --format="value(email)" | fzf)
if [ -z "$service_account" ]; then
  echo -e "${RED}No service account selected.${NC}"
  exit 1
fi

# 查詢選定的 service account 的權限
echo "Selected Service Account: $service_account"
# roles/iam
echo -e "${BLUE}Service Account Permissions:${NC}"
gcloud projects get-iam-policy $current_project --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$service_account"
# workload identity
echo -e "${BLUE}Service Account Workload Identity:${NC}"
gcloud iam service-accounts get-iam-policy $service_account
