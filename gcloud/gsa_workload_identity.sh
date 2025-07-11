#!/bin/bash
source ../modules/default.sh
source ../modules/gcloud_operate.sh

# 查詢 Service Account 的 Workload Identity 綁定
query_workload_identity() {
    local SERVICE_ACCOUNT="$1"

    echo -e "${BLUE}=== Workload Identity 和其他權限綁定 ===${NC}"

    # 查詢該 Service Account 的 IAM 政策
    local WI_RESULT
    local WI_ERROR
    WI_RESULT=$(gcloud iam service-accounts get-iam-policy "$SERVICE_ACCOUNT" \
        --project="$CURRENT_PROJECT" \
        --format="json" 2>&1)
    WI_ERROR=$?
    
    # 檢查指令執行是否成功
    if [ $WI_ERROR -ne 0 ]; then
        echo -e "${RED}查詢 IAM 政策時發生錯誤:${NC}"
        echo -e "${YELLOW}$WI_RESULT${NC}"
        return 1
    fi
    
    # 檢查結果是否為空或無效
    if [ -z "$WI_RESULT" ] || [ "$WI_RESULT" = "{}" ] || [ "$WI_RESULT" = "null" ]; then
        echo -e "${YELLOW}該 Service Account 沒有任何 IAM 政策綁定${NC}"
        return 0
    fi
    
    # 檢查是否有 bindings
    local HAS_BINDING
    HAS_BINDING=$(echo "$WI_RESULT" | jq -r '.bindings // empty | length')
    
    if [ "$HAS_BINDING" = "0" ] || [ -z "$HAS_BINDING" ]; then
        echo -e "${YELLOW}該 Service Account 沒有任何權限綁定${NC}"
        return 0
    fi
    
    echo -e "${GREEN}找到以下綁定：${NC}"
    
    # 分別顯示不同類型的綁定
    echo "$WI_RESULT" | jq -r '
    .bindings[]? |
    select(.role and .members) |
    .role as $role |
    .members[] as $member |
    if ($member | startswith("serviceAccount:")) then
        "🔗 Service Account 綁定: \($role) → \($member)"
    elif ($member | startswith("user:")) then
        "👤 使用者綁定: \($role) → \($member)"
    elif ($member | startswith("group:")) then
        "👥 群組綁定: \($role) → \($member)"
    elif ($member | contains("workload-identity")) then
        "⚙️ Workload Identity: \($role) → \($member)"
    else
        "🔧 其他綁定: \($role) → \($member)"
    end
    ' | while IFS= read -r binding; do
        if [ -n "$binding" ]; then
            echo -e "${YELLOW}$binding${NC}"
        fi
    done

  return 0
}

# 檢查 GKE 集群的 Workload Identity 設定
check_gke_workload_identity() {
    echo -e "${BLUE}=== GKE 集群 Workload Identity 設定檢查 ===${NC}"
    
    # 取得所有 GKE 集群
    local clusters
    clusters=$(gcloud container clusters list --project="$CURRENT_PROJECT" --format="value(name,location)" 2>/dev/null)
    
    if [ -z "$clusters" ]; then
        echo -e "${YELLOW}  在此專案中沒有找到 GKE 集群${NC}"
        return 0
    fi
    
    echo -e "${GREEN}檢查以下集群的 Workload Identity 設定：${NC}"
    
    while IFS=$'\t' read -r cluster_name location; do
        if [ -n "$cluster_name" ] && [ -n "$location" ]; then
            echo -e "\n  ${CYAN}集群: ${YELLOW}$cluster_name${NC} (${YELLOW}$location${NC})"
            
            # 檢查集群是否啟用 Workload Identity
            local wi_enabled
            wi_enabled=$(gcloud container clusters describe "$cluster_name" \
                --location="$location" \
                --project="$CURRENT_PROJECT" \
                --format="value(workloadIdentityConfig.workloadPool)" 2>/dev/null)
            
            if [ -n "$wi_enabled" ]; then
                echo -e "    ${GREEN}✅ Workload Identity 已啟用${NC}"
                echo -e "    ${BLUE}Workload Pool: ${YELLOW}$wi_enabled${NC}"
            else
                echo -e "    ${RED}❌ Workload Identity 未啟用${NC}"
            fi
        fi
    done <<< "$clusters"
}

# 查詢 Service Account 的詳細資訊
query_service_account_details() {
    local SERVICE_ACCOUNT="$1"

    echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"

    # 獲取 Service Account 詳細資訊
    gcloud iam service-accounts describe "$SERVICE_ACCOUNT" \
        --project="$CURRENT_PROJECT" \
        --format="table(displayName:label='顯示名稱',description:label='描述',disabled:label='是否停用')"

    echo ""
}

# 顯示使用說明
show_usage_tips() {
    echo -e "${CYAN}=== 使用提示 ===${NC}"
    echo -e "${YELLOW}• 此腳本專門查詢 Service Account 的 Workload Identity 綁定${NC}"
    echo -e "${YELLOW}• 檢查範圍：Service Account 層級的 IAM 政策綁定${NC}"
    echo -e "${YELLOW}• 如需檢查 IAM 角色權限，請使用 gsa_iam_roles.sh${NC}"
    echo -e "${YELLOW}• 需要 jq 工具來解析 JSON 結果${NC}"
    echo ""
}

# 主要功能
main() {
    current_gcp_project

    echo -e "${CYAN}正在取得 Service Account 清單...${NC}"

    # 列出所有 service accounts 並使用 fzf 選擇
    SERVICE_ACCOUNT=$(gcloud iam service-accounts list \
        --project="$CURRENT_PROJECT" \
        --format="value(email)" | \
        fzf --prompt="選擇 Service Account: " --height=60% --border)

    if [ -z "$SERVICE_ACCOUNT" ]; then
        echo -e "${YELLOW}未選擇 Service Account，退出腳本${NC}"
        exit 0
    fi

    echo -e "${GREEN}已選擇 Service Account: ${YELLOW}$SERVICE_ACCOUNT${NC}"

    # 顯示 Service Account 詳細資訊
    query_service_account_details "$SERVICE_ACCOUNT"
    
    # 查詢 Workload Identity 綁定
    query_workload_identity "$SERVICE_ACCOUNT"
    echo ""
    
    # 檢查 GKE 集群設定
    check_gke_workload_identity
    echo ""
    
    echo -e "${GREEN}✅ Workload Identity 綁定查詢完成！${NC}"
    echo -e "${CYAN}如需檢查 IAM 角色權限，請執行 gsa_iam_roles.sh${NC}"
}

# 執行主函數
main