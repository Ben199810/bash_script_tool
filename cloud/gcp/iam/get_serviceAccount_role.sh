#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

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

function query_service_account_roles() {
  local SERVICE_ACCOUNT="$1"

  local IAM_ROLES=$(gcloud projects get-iam-policy "$CURRENT_PROJECT_ID" \
    --flatten="bindings[].members" \
    --format="value(bindings.role)" \
    --filter="bindings.members:$SERVICE_ACCOUNT")

  if [ -z "$IAM_ROLES" ]; then
    echo -e "${YELLOW}該 Service Account 在專案層級中沒有任何 IAM 角色綁定${NC}"
    exit 0
  else
    echo -e "${BLUE}=== 該 Service Account 的 IAM 角色綁定 ===${NC}"
    echo "$IAM_ROLES"
    echo ""
  fi
  echo -e "${GREEN}✅ Service Account 角色查詢完成！${NC}"
}

function main () {
  ask_switch_gcp_project_interface
  select_service_account
  query_service_account_roles "$SELECTED_SERVICE_ACCOUNT"
}

main