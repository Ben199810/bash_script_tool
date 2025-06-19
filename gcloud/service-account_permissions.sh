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
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}錯誤: 缺少必要工具: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}請安裝缺少的工具後再執行此腳本${NC}"
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

# 查詢 Service Account 的 IAM 權限
query_iam_permissions() {
    local service_account="$1"
    local found_permissions=false
    
    echo -e "${BLUE}=== 專案層級的 IAM 角色權限 ===${NC}"
    
    # 使用更詳細的查詢格式
    local iam_result
    iam_result=$(gcloud projects get-iam-policy "$CURRENT_PROJECT" \
        --flatten="bindings[].members" \
        --format="value(bindings.role)" \
        --filter="bindings.members:$service_account")
    
    if [ -n "$iam_result" ]; then
        echo -e "${GREEN}找到以下 IAM 角色：${NC}"
        echo "$iam_result" | while read -r role; do
            echo -e "  ${YELLOW}• $role${NC}"
        done
        found_permissions=true
    else
        echo -e "${YELLOW}  該 Service Account 在專案層級沒有 IAM 角色${NC}"
    fi
    
    return 0
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
    
    # 使用 jq 解析 JSON 結果
    if command -v jq &> /dev/null; then
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
            done
        fi
        
    else
        # 沒有 jq 時的備用方案
        echo -e "${YELLOW}  (建議安裝 jq 以獲得更好的顯示效果)${NC}"
        gcloud iam service-accounts get-iam-policy "$service_account" \
            --project="$CURRENT_PROJECT" \
            --format="table(bindings.role:label='角色',bindings.members.join(','):label='成員')"
    fi
}

# 查詢 Service Account 的詳細資訊
query_service_account_details() {
    local service_account="$1"
    
    echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"
    
    # 獲取 Service Account 詳細資訊
    gcloud iam service-accounts describe "$service_account" \
        --project="$CURRENT_PROJECT" \
        --format="table(displayName:label='顯示名稱',description:label='描述')"

    echo ""
}

# 主要功能
main() {
    echo -e "${BLUE}=== Service Account 權限查詢工具 ===${NC}"
    
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
    
    # 查詢 IAM 權限
    query_iam_permissions "$SERVICE_ACCOUNT"
    echo ""
    
    # 查詢 Workload Identity
    query_workload_identity "$SERVICE_ACCOUNT"
    echo ""
    
    echo -e "${GREEN}✅ 查詢完成！${NC}"
}

# 執行主函數
main
