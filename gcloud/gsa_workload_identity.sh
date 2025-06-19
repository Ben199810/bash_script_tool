#!/bin/bash

# 取得腳本目錄
SCRIPT_DIR="$(dirname $0)"

# 引入必要模組
source "$SCRIPT_DIR/../modules/default.sh"
source "$SCRIPT_DIR/../modules/gcloud_operate.sh"

# 檢查必要工具
check_dependencies() {
    local missing_tools=()
    
    if ! command -v gcloud &> /dev/null; then
        missing_tools+=("gcloud")
    fi
    
    if ! command -v fzf &> /dev/null; then
        missing_tools+=("fzf")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}錯誤: 缺少必要工具: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}請安裝缺少的工具後再執行此腳本${NC}"
        echo -e "${YELLOW}提示: brew install jq fzf${NC}"
        exit 1
    fi
}

# 檢查 gcloud 認證狀態
check_gcloud_auth() {
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 &> /dev/null; then
        echo -e "${RED}錯誤: gcloud 未認證，請先執行 'gcloud auth login'${NC}"
        exit 1
    fi
}

# 取得當前專案
get_current_project() {
    CURRENT_PROJECT=$(gcloud config get-value project)
    if [ -z "$CURRENT_PROJECT" ]; then
        echo -e "${RED}錯誤: 未設定 GCP 專案，請先設定專案${NC}"
        exit 1
    fi
    echo -e "${BLUE}當前 GCP 專案: ${YELLOW}$CURRENT_PROJECT${NC}"
}

# 查詢 Service Account 的 Workload Identity 綁定
query_workload_identity() {
    local service_account="$1"
    
    echo -e "${BLUE}=== Workload Identity 和其他權限綁定 ===${NC}"
    
    # 先檢查是否有權限查詢該 Service Account
    if ! gcloud iam service-accounts describe "$service_account" --project="$CURRENT_PROJECT" &>/dev/null; then
        echo -e "${RED}  錯誤: 無法存取該 Service Account 或權限不足${NC}"
        return 1
    fi
    
    # 查詢該 Service Account 的 IAM 政策
    local wi_result
    local wi_error
    wi_result=$(gcloud iam service-accounts get-iam-policy "$service_account" \
        --project="$CURRENT_PROJECT" \
        --format="json" 2>&1)
    wi_error=$?
    
    # 檢查指令執行是否成功
    if [ $wi_error -ne 0 ]; then
        echo -e "${RED}  查詢 IAM 政策時發生錯誤:${NC}"
        echo -e "${YELLOW}  $wi_result${NC}"
        return 1
    fi
    
    # 檢查結果是否為空或無效
    if [ -z "$wi_result" ] || [ "$wi_result" = "{}" ] || [ "$wi_result" = "null" ]; then
        echo -e "${YELLOW}  該 Service Account 沒有任何 IAM 政策綁定${NC}"
        return 0
    fi
    
    # 檢查是否有 bindings
    local has_bindings
    has_bindings=$(echo "$wi_result" | jq -r '.bindings // empty | length')
    
    if [ "$has_bindings" = "0" ] || [ -z "$has_bindings" ]; then
        echo -e "${YELLOW}  該 Service Account 沒有任何權限綁定${NC}"
        return 0
    fi
    
    echo -e "${GREEN}找到以下綁定：${NC}"
    
    # 分別顯示不同類型的綁定
    echo "$wi_result" | jq -r '
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
        "⚙️  Workload Identity: \($role) → \($member)"
    else
        "🔧 其他綁定: \($role) → \($member)"
    end
    ' | while IFS= read -r binding; do
        if [ -n "$binding" ]; then
            echo -e "  ${YELLOW}$binding${NC}"
        fi
    done
    
    # 額外顯示 Workload Identity 相關資訊
    local wi_bindings
    wi_bindings=$(echo "$wi_result" | jq -r '.bindings[]? | select(.members[]? | contains("workload-identity")) | .members[]')
    
    if [ -n "$wi_bindings" ]; then
        echo -e "\n${CYAN}  Workload Identity 詳細資訊：${NC}"
        echo "$wi_bindings" | while IFS= read -r member; do
            echo -e "    ${GREEN}→ $member${NC}"
            
            # 解析 Workload Identity 格式並提供更多資訊
            if [[ "$member" =~ serviceAccount:.*\.svc\.id\.goog\[(.*)/(.*)\] ]]; then
                local namespace="${BASH_REMATCH[1]}"
                local ksa="${BASH_REMATCH[2]}"
                echo -e "      ${BLUE}Kubernetes Namespace: ${YELLOW}$namespace${NC}"
                echo -e "      ${BLUE}Kubernetes Service Account: ${YELLOW}$ksa${NC}"
            fi
        done
    else
        echo -e "\n${YELLOW}  沒有找到 Workload Identity 綁定${NC}"
    fi
    
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
    local service_account="$1"
    
    echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"
    
    # 獲取 Service Account 詳細資訊
    gcloud iam service-accounts describe "$service_account" \
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
    echo -e "${BLUE}=== GSA Workload Identity 綁定查詢工具 ===${NC}"
    
    # 顯示使用說明
    show_usage_tips
    
    # 執行檢查
    check_dependencies
    check_gcloud_auth
    get_current_project
    
    echo ""
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
    
    echo ""
    echo -e "${GREEN}已選擇 Service Account: ${YELLOW}$SERVICE_ACCOUNT${NC}"
    echo ""
    
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