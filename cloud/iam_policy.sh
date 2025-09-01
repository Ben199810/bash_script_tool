#!/bin/bash
source ../modules/default.sh
source ../modules/gcloud_operate.sh

# 初始化當前項目
current_gcp_project

# 顯示選單函數
show_menu() {
  echo -e "${BLUE}=== IAM Policy 管理工具 ===${NC}"
  echo -e "${PURPLE}1. 查看 Service Account 資訊 (service_account_info)${NC}"
  echo -e "${PURPLE}2. 查看 IAM 權限 (iam_permissions)${NC}"
  echo -e "${PURPLE}3. 查看 Workload Identity 綁定 (workload_identity)${NC}"
  echo -e "${PURPLE}4. 查看 GKE 集群的 Workload Identity 狀態 (gke_workload_identity)${NC}"
  echo -e "${PURPLE}0. 退出 (exit)${NC}"
  echo -e "${BLUE}================================${NC}"
}

# 主程式循環
while true; do
  show_menu
  read -p "請選擇操作 (0-4): " choice
  case $choice in
    1)
      OPERATE="service_account_info"
      ;;
    2)
      OPERATE="iam_permissions"
      ;;
    3)
      OPERATE="workload_identity"
      ;;
    4)
      OPERATE="gke_workload_identity"
      ;;
    0)
      OPERATE="exit"
      echo -e "${GREEN}退出程式${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}無效的選擇${NC}"
      exit 1
      ;;
  esac

  # 主要功能列表
  case $OPERATE in
    "service_account_info")
      choose_service_account
      query_service_account_details $SERVICE_ACCOUNT
    ;;
    "iam_permissions")
      choose_service_account
      query_iam_permissions $SERVICE_ACCOUNT
    ;;
    "workload_identity")
      choose_service_account
      query_workload_identity $SERVICE_ACCOUNT
    ;;
    "gke_workload_identity")
      check_gke_workload_identity
    ;;
  esac
done