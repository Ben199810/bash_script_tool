#!/bin/bash
# 取得 Cloud Armor 規則
source ../modules/default.sh
source ../modules/switch_gcp_project_enabled.sh

# 顯示目前的 GCP 專案
current_project=$(gcloud config get-value project)

# 取得所有的 Cloud Armor 規則
echo -e "${BLUE}Cloud Armor 規則:${NC}"
gcloud compute security-policies list --project=$current_project

# 遞迴取得所有規則的詳細資訊
# for policy in $(gcloud compute security-policies list --project=$current_project --format="value(name)"); do
#   echo -e "${BLUE}Cloud Armor 規則詳細資訊:${NC}"
#   gcloud compute security-policies describe $policy --project=$current_project
# done

# fzf 選擇規則，再取得詳細資訊
selected_policy=$(gcloud compute security-policies list --project=$current_project --format="value(name)" | fzf)
if [ -n "$selected_policy" ]; then
  echo -e "${BLUE}Selected Cloud Armor Policy: $selected_policy${NC}"
  gcloud compute security-policies describe $selected_policy --project=$current_project
else
  echo -e "${RED}No policy selected.${NC}"
  exit 1
fi