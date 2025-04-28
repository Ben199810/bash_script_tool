#!/bin/bash
source ../gcloud/switch_project.sh

# 輸入要查詢的 serviceAccount
read -p "Enter the service account (e.g. [SERVICE_ACCOUNT]@[PROJECT_ID].iam.gserviceaccount.com): " SERVICE_ACCOUNT

# roles/iam
echo -e "${BLUE}Service Account Permissions:${NC}"

gcloud projects get-iam-policy $CURRENT_PROJECT --flatten="bindings[].members" --filter="bindings.members:$SERVICE_ACCOUNT" --format="table(bindings.role, bindings.members)"