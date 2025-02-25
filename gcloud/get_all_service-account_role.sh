#!/usr/local/bin/bash
# declare 需要 bash 4.2 以上版本, /usr/local/bin/bash 執行

source ../modules/default.sh
source ../modules/switch_gcp_project_enabled.sh

# 顯示目前的 GCP 專案
current_project=$(gcloud config get-value project)
echo -e "${BLUE}Current GCP Project: $current_project${NC}"

# 獲取專案的 IAM 政策
iam_policy=$(gcloud projects get-iam-policy "$current_project" --format=json)

# 檢查是否成功獲取 IAM 政策
if [ -z "$iam_policy" ]; then
    echo "Failed to retrieve IAM policy for the project $project_id."
    exit 1
fi

# 顯示所有的服務帳戶
echo -e "${BLUE}Service Accounts:${NC}"

echo "$iam_policy"