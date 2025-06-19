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
    
    # 查詢資源層級的權限（可選）
    echo -e "\n${BLUE}=== 檢查其他層級的 IAM 角色 ===${NC}"
    echo -e "${CYAN}提示: 此腳本目前只檢查專案層級權限${NC}"
    echo -e "${CYAN}如需檢查資源層級權限，請使用 gcloud 指令手動查詢${NC}"
    
    return 0
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
    echo -e "${YELLOW}• 此腳本專門查詢 Service Account 的 IAM 角色權限${NC}"
    echo -e "${YELLOW}• 目前檢查範圍：專案層級的 IAM 政策${NC}"
    echo -e "${YELLOW}• 如需檢查 Workload Identity 綁定，請使用 gsa_workload_identity.sh${NC}"
    echo ""
}

# 主要功能
main() {
    echo -e "${BLUE}=== GSA IAM 角色權限查詢工具 ===${NC}"
    
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
    
    # 查詢 IAM 權限
    query_iam_permissions "$SERVICE_ACCOUNT"
    echo ""
    
    echo -e "${GREEN}✅ IAM 角色權限查詢完成！${NC}"
    echo -e "${CYAN}如需檢查 Workload Identity 綁定，請執行 gsa_workload_identity.sh${NC}"
}

# 執行主函數
main