query_service_account_details(){
  local SERVICE_ACCOUNT="$1"

  echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"
  gcloud iam service-accounts describe "$SERVICE_ACCOUNT" \
    --project="$CURRENT_PROJECT" \
    --format="table(displayName:label='顯示名稱',description:label='描述',disabled:label='是否停用')"
  echo -e "${GREEN}✅ Service Account 基本資訊查詢完成！${NC}"
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