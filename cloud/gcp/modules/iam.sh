# 選擇 Service Account
# 設定全域變數 SELECTED_SERVICE_ACCOUNT
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

# 列出所有 Service Accounts
function list_service_accounts() {
  echo -e "${BLUE}Listing Service Accounts in project: $CURRENT_PROJECT_ID${NC}"

  local service_accounts=$(gcloud iam service-accounts list \
    --project="$CURRENT_PROJECT_ID" \
    --format="value(email)")

  if [ -z "$service_accounts" ]; then
    echo -e "${YELLOW}No service accounts found in project: $CURRENT_PROJECT_ID${NC}"
  else
    echo "$service_accounts"
  fi
}

# 查詢 Service Account 的 IAM 角色
function query_service_account_roles() {
  select_service_account

  local iam_roles=$(gcloud projects get-iam-policy "$CURRENT_PROJECT_ID" \
    --flatten="bindings[].members" \
    --format="value(bindings.role)" \
    --filter="bindings.members:$SELECTED_SERVICE_ACCOUNT")

  if [ -z "$iam_roles" ]; then
    echo -e "${YELLOW}該 Service Account 在專案層級中沒有任何 IAM 角色綁定${NC}"
  else
    echo -e "${BLUE}=== 該 Service Account 的 IAM 角色綁定 ===${NC}"
    echo "$iam_roles"
    echo ""
  fi
  echo -e "${GREEN}✅ Service Account 角色綁定查詢完成！${NC}"
}

# 查詢 Service Account 的 Workload Identity 綁定
function query_service_account_workload_identity() {
  select_service_account

  echo -e "${BLUE}正在查詢 Service Account 的 Workload Identity 綁定...${NC}"
  
  local wi_result=$(gcloud iam service-accounts get-iam-policy "$SELECTED_SERVICE_ACCOUNT" \
    --project="$CURRENT_PROJECT_ID" \
    --format="json")

  if [ -z "$wi_result" ] || [ "$wi_result" = "{}" ] || [ "$wi_result" = "null" ]; then
    echo -e "${YELLOW}該 Service Account 沒有任何 Workload Identity 綁定${NC}"
  else
    echo -e "${BLUE}=== 該 Service Account 的 Workload Identity 綁定資訊 ===${NC}"
    
    local bindings=$(echo "$wi_result" | jq -r '.bindings[]? | "\(.role): \(.members | join(", "))"')

    if [ -n "$bindings" ]; then
      echo -e "${GREEN}找到以下 Bindings：${NC}"
      echo "$bindings" | while IFS=': ' read -r role members; do
        echo -e "${YELLOW}角色: ${CYAN}$role${NC}"
        echo -e "${YELLOW}成員: ${CYAN}$members${NC}"
      done
      echo ""
    else
      echo -e "${YELLOW}沒有找到任何 Bindings${NC}"
    fi
  fi

  echo -e "${GREEN}✅ Service Account Workload Identity 綁定查詢完成！${NC}"
}