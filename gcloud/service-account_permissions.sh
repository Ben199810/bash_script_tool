#!/bin/bash

# 顯示目前的 GCP 專案
current_project=$(gcloud config get-value project)
echo "Current GCP Project: $current_project"

# 列出所有 service accounts 並使用 fzf 選擇
service_account=$(gcloud iam service-accounts list --format="value(email)" | fzf)
if [ -z "$service_account" ]; then
  echo "No service account selected."
  exit 1
fi

# 查詢選定的 service account 的權限
echo "Selected Service Account: $service_account"
gcloud projects get-iam-policy $current_project --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:$service_account"
