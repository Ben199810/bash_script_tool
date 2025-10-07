#!/bin/bash
# GCP 統一管理腳本
# 整合 IAM、Network、IAP、Memorystore 等 GCP 資源操作

DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "modules/switch_gcp_project.sh"
source "modules/memorystore.sh"
source "modules/network.sh"
source "modules/iap.sh"
source "modules/iam.sh"

# ============================================
# 主選單
# ============================================

function main_menu() {
  local MAIN_OPERATIONS=(
    "IAM - 列出 Service Accounts"
    "IAM - 查詢 Service Account 角色"
    "IAM - 查詢 Service Account Workload Identity"
    "Network - 搜尋 IP 地址"
    "IAP - 透過 IAP 連線到 GCE"
    "IAP - 透過 IAP Port Forward 到 Memorystore"
    "Memorystore - 列出實例"
    "切換 GCP 專案"
    "離開"
  )
  
  while true; do
    echo ""
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}   GCP 資源管理工具${NC}"
    echo -e "${CYAN}================================${NC}"
    get_current_gcp_project
    
    local OPERATION=$(printf "%s\n" "${MAIN_OPERATIONS[@]}" | fzf --header="選擇操作:" --prompt="操作: ")
    
    case $OPERATION in
      "IAM - 列出 Service Accounts")
        list_service_accounts
        ;;
      "IAM - 查詢 Service Account 角色")
        query_service_account_roles
        ;;
      "IAM - 查詢 Service Account Workload Identity")
        query_service_account_workload_identity
        ;;
      "Network - 搜尋 IP 地址")
        find_ip_in_project
        ;;
      "IAP - 透過 IAP 連線到 GCE")
        start_iap_tunnel
        ;;
      "IAP - 透過 IAP Port Forward 到 Memorystore")
        use_iap_tunnel_port_forwarding_memorystore
        ;;
      "Memorystore - 列出實例")
        list_memorystore_instances
        ;;
      "切換 GCP 專案")
        switch_gcp_project
        ;;
      "離開")
        echo -e "${GREEN}再見！${NC}"
        exit 0
        ;;
      *)
        if [ -z "$OPERATION" ]; then
          echo -e "${YELLOW}未選擇操作，退出...${NC}"
          exit 0
        fi
        echo -e "${RED}無效的選擇${NC}"
        ;;
    esac
    
    echo ""
    read -p "按 Enter 繼續..."
  done
}

# ============================================
# 執行主程式
# ============================================

# 初始化：詢問是否切換專案
ask_switch_gcp_project_interface

# 啟動主選單
main_menu
