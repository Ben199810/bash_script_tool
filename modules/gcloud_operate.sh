current_gcp_project() {
  CURRENT_PROJECT=$(gcloud config get-value project)
  echo -e "${BLUE}Current GCP project: $CURRENT_PROJECT${NC}"
}

switch_gcp_project() {
  # 列出所有的 GCP 項目
  local PROJECTS=$(gcloud projects list --format="value(projectId)")

  # 將項目 ID 儲存在一個陣列中
  local PROJECT_ARRARY=()
  while IFS= read -r PROJECT; do
    PROJECT_ARRARY+=("$PROJECT")
  done <<< "$PROJECTS"

  # 顯示所有項目 ID 並讓用戶選擇
  local SELECT_PROJECT=$(printf "%s\n" "${PROJECT_ARRARY[@]}" | fzf --prompt="Select a GCP project: ")

  # 檢查用戶是否選擇了項目
  if [ -n "$SELECT_PROJECT" ]; then
    gcloud config set project "$SELECT_PROJECT" > /dev/null 2>&1
    echo -e "${GREEN}Switched to project: $(gcloud config get-value project)${NC}"
  else
    echo -e "${RED}No project selected. Exiting.${NC}"
    exit 1
  fi
}

choose_service_account() {
  SERVICE_ACCOUNT=$(gcloud iam service-accounts list \
      --project="$CURRENT_PROJECT" \
      --format="value(email)" | \
      fzf --prompt="選擇 Service Account: " --height=60% --border)
  # 檢查是否選擇了 Service Account
  if [ -z "$SERVICE_ACCOUNT" ]; then
      echo -e "${YELLOW}未選擇 Service Account，退出腳本${NC}"
      exit 0
  fi
  echo -e "${GREEN}已選擇 Service Account: ${YELLOW}$SERVICE_ACCOUNT${NC}"
}

query_service_account_details(){
  local SERVICE_ACCOUNT="$1"

  echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"
  gcloud iam service-accounts describe "$SERVICE_ACCOUNT" \
      --project="$CURRENT_PROJECT" \
      --format="table(displayName:label='顯示名稱',description:label='描述',disabled:label='是否停用')"
  echo -e "${GREEN}✅ Service Account 基本資訊查詢完成！${NC}"
}

query_iam_permissions() {
  local SERVICE_ACCOUNT="$1"
  echo -e "${BLUE}=== 專案層級的 IAM 角色權限 ===${NC}"

  # 使用更詳細的查詢格式
  local IAM_RESULT
  IAM_RESULT=$(gcloud projects get-iam-policy "$CURRENT_PROJECT" \
      --flatten="bindings[].members" \
      --format="value(bindings.role)" \
      --filter="bindings.members:$SERVICE_ACCOUNT")
  if [ -n "$IAM_RESULT" ]; then
    echo -e "${GREEN}找到以下 IAM 角色：${NC}"
    echo "$IAM_RESULT" | while read -r role; do
      echo -e "${YELLOW}• $role${NC}"
    done
  else
    echo -e "${YELLOW}該 Service Account 在專案層級沒有 IAM 角色${NC}"
  fi
  echo -e "${GREEN}✅ IAM 角色權限查詢完成！${NC}"
}

