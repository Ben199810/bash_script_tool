#!/bin/bash
source ../../../modules/default.sh
source ../modules/switch_gcp_project.sh
source ../modules/iam.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "列出 Service Accounts"
  "查詢 Service Account 角色"
  "查詢 Service Account Workload Identity"
)

# 顯示操作選項並讓使用者選擇
function show_operation_menu() {
  printf "%b%s%b\n" "${CYAN}" "=== GCP IAM 操作選單 ===" "${NC}"
  for i in "${!OPERATION_OPTIONS[@]}"; do
    printf "%b%d)%b %s\n" "${YELLOW}" $((i + 1)) "${NC}" "${OPERATION_OPTIONS[$i]}"
  done
  printf "\n"
}

# 主程式
function main() {
  # 初始化：詢問是否切換專案
  ask_switch_gcp_project_interface
  
  show_operation_menu
  
  local choice=""
  read -rp "請選擇操作選項 (1-${#OPERATION_OPTIONS[@]}): " choice
  
  case "${choice}" in
    1)
      list_service_accounts
      ;;
    2)
      query_service_account_roles
      ;;
    3)
      query_service_account_workload_identity
      ;;
    *)
      printf "%b%s%b\n" "${RED}" "無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}" "${NC}"
      exit 1
      ;;
  esac
  
  printf "%b%s%b\n" "${GREEN}" "✅ 操作完成！" "${NC}"
}

main

