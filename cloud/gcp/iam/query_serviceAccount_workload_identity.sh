#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

# 查看指定服務帳戶的 workload identity 綁定資訊

function query_service_account_workload_identity () {
  local SERVICE_ACCOUNT="$1"

  WI_RESULT=$(gcloud iam service-accounts get-iam-policy "$SERVICE_ACCOUNT" \
    --project="$CURRENT_PROJECT_ID" \
    --format="json")

  if [ -z "$WI_RESULT" ] || [ "$WI_RESULT" = "{}" ] || [ "$WI_RESULT" = "null" ]; then
    echo -e "${YELLOW}該 Service Account 沒有任何 Workload Identity 綁定${NC}"
    exit 0
  else
    echo -e "${BLUE}=== 該 Service Account 的 Workload Identity 綁定資訊 ===${NC}"
    
    local BINDINGS=$(echo "$WI_RESULT" | jq -r '.bindings[]? | "\(.role): \(.members | join(", "))"')

    if [ -n "$BINDINGS" ]; then
      echo -e "${GREEN}找到以下 Bindings：${NC}"
      echo "$BINDINGS" | while IFS=': ' read -r role members; do
        echo -e "${YELLOW}角色: ${CYAN}$role${NC}"
        echo -e "${YELLOW}成員: ${CYAN}$members${NC}"
      done
      echo ""
    else
      echo -e "${YELLOW}沒有找到任何 Bindings${NC}"
      exit 0
    fi
  fi

  echo -e "${GREEN}✅ Service Account Workload Identity 綁定查詢完成！${NC}"
}

function main () {
  ask_switch_gcp_project_interface
  select_service_account
  query_service_account_workload_identity "$SELECTED_SERVICE_ACCOUNT"
}

main