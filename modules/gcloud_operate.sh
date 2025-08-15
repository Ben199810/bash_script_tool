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

query_workload_identity() {
  local SERVICE_ACCOUNT="$1"
  local WI_RESULT

  echo -e "${BLUE}=== 查詢 Workload Identity 綁定 ===${NC}"
  # 獲取完整的 IAM policy
  WI_RESULT=$(gcloud iam service-accounts get-iam-policy "$SERVICE_ACCOUNT" \
    --project="$CURRENT_PROJECT" \
    --format="json")
  # 檢查結果是否為空或無效
  if [ -z "$WI_RESULT" ] || [ "$WI_RESULT" = "{}" ] || [ "$WI_RESULT" = "null" ]; then
    echo -e "${YELLOW}該 Service Account 沒有任何 IAM 政策綁定${NC}"
    exit 0
  fi
  # 提取並顯示 bindings 資訊
  local BINDINGS=$(echo "$WI_RESULT" | jq -r '.bindings[]? | "\(.role): \(.members | join(", "))"')
  if [ -n "$BINDINGS" ]; then
    echo -e "${GREEN}找到以下 Bindings：${NC}"
    echo "$BINDINGS" | while IFS=': ' read -r role members; do
      echo -e "${YELLOW}角色: ${CYAN}$role${NC}"
      echo -e "${YELLOW}成員: ${CYAN}$members${NC}"
    done
  else
    echo -e "${YELLOW}沒有找到任何 Bindings${NC}"
  fi
  echo -e "${GREEN}✅ Workload Identity 查詢完成！${NC}"
}

check_gke_workload_identity() {
  echo -e "${BLUE}=== GKE 集群 Workload Identity 設定檢查 ===${NC}"
  # 取得所有 GKE 集群
  local CLUSTERS
  CLUSTERS=$(gcloud container clusters list --project="$CURRENT_PROJECT" --format="value(name,location)")
  # 檢查是否有 GKE 集群
  if [ -z "$CLUSTERS" ]; then
    echo -e "${YELLOW}  在此專案中沒有找到 GKE 集群${NC}"
    return 0
  fi
  echo -e "${GREEN}檢查以下集群的 Workload Identity 設定：${NC}"
  # 遍歷每個集群並檢查 Workload Identity 設定
  while IFS=$'\t' read -r CLUSTER_NAME LOCATION; do
    if [ -n "$CLUSTER_NAME" ] && [ -n "$LOCATION" ]; then
      echo -e "\n${CYAN}集群: ${YELLOW}$CLUSTER_NAME${NC} (${YELLOW}$LOCATION${NC})"
      # 檢查集群是否啟用 Workload Identity
      local wi_enabled
      wi_enabled=$(gcloud container clusters describe "$CLUSTER_NAME" \
        --location="$LOCATION" \
        --project="$CURRENT_PROJECT" \
        --format="value(workloadIdentityConfig.workloadPool)")
      if [ -n "$wi_enabled" ]; then
        echo -e "${GREEN}✅ Workload Identity 已啟用${NC}"
        echo -e "${BLUE}Workload Pool: ${YELLOW}$wi_enabled${NC}"
      else
        echo -e "${RED}❌ Workload Identity 未啟用${NC}"
      fi
    fi
  done <<< "$CLUSTERS"
}