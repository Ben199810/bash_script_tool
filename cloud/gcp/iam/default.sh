#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../../modules/default.sh"
source "$DIR/../../../modules/switch_gcp_project.sh"

function select_service_account() {
  SELECTED_SERVICE_ACCOUNT=$(gcloud iam service-accounts list \
    --project="$CURRENT_PROJECT_ID" \
    --format="value(email)" | \
    fzf --prompt="選擇 Service Account: ")

  if [ -z "$SELECTED_SERVICE_ACCOUNT" ]; then
    echo -e "${YELLOW}未選擇 Service Account，退出腳本${NC}"
    exit 0
  fi
    echo -e "${GREEN}已選擇 Service Account: ${YELLOW}$SELECTED_SERVICE_ACCOUNT${NC}"
    echo ""
}