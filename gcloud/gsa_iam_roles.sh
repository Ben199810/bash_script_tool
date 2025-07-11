#!/bin/bash

source ../modules/default.sh
source ../modules/gcloud_operate.sh

# 查詢 Service Account 的 IAM 權限
query_iam_permissions() {
    local SERVICE_ACCOUNT="$1"
    local FOUND_PERMISSIONS=false

    echo -e "${BLUE}=== 專案層級的 IAM 角色權限 ===${NC}"

    # 使用更詳細的查詢格式
    local iam_result
    iam_result=$(gcloud projects get-iam-policy "$CURRENT_PROJECT" \
        --flatten="bindings[].members" \
        --format="value(bindings.role)" \
        --filter="bindings.members:$SERVICE_ACCOUNT")
    
    if [ -n "$iam_result" ]; then
        echo -e "${GREEN}找到以下 IAM 角色：${NC}"
        echo "$iam_result" | while read -r role; do
            echo -e "${YELLOW}• $role${NC}"
        done
        FOUND_PERMISSIONS=true
    else
        echo -e "${YELLOW}  該 Service Account 在專案層級沒有 IAM 角色${NC}"
    fi
}

# 查詢 Service Account 的詳細資訊
query_service_account_details() {
    local SERVICE_ACCOUNT="$1"
    
    echo -e "${BLUE}=== Service Account 基本資訊 ===${NC}"
    
    # 獲取 Service Account 詳細資訊
    gcloud iam service-accounts describe "$SERVICE_ACCOUNT" \
        --project="$CURRENT_PROJECT" \
        --format="table(displayName:label='顯示名稱',description:label='描述',disabled:label='是否停用')"
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

    # 查詢 IAM 權限
    query_iam_permissions "$SERVICE_ACCOUNT"

    echo -e "${GREEN}✅ IAM 角色權限查詢完成！${NC}"
}

# 執行主函數
main