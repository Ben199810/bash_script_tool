#!/bin/bash
source ../../../modules/default.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "查詢 IAM Role 列表"
)

# 顯示操作選項並讓使用者選擇
function show_operation_menu() {
  echo -e "${CYAN}=== IAM 操作選單 ===${NC}"
  for i in "${!OPERATION_OPTIONS[@]}"; do
    printf "${YELLOW}%d)${NC} %s\n" $((i + 1)) "${OPERATION_OPTIONS[$i]}"
  done
  echo ""
}

# 查詢 IAM Role 列表
function list_iam_roles() {
  echo -e "${BLUE}正在查詢 IAM Role 列表...${NC}"
  
  local roles
  roles=$(aws iam list-roles --query "Roles[*].[RoleName, CreateDate, Description]" --output text 2>&1)
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}無法查詢 IAM Role。請確保您已配置 AWS CLI 並擁有適當的權限。${NC}"
    exit 1
  fi
  
  if [[ -z "${roles}" ]]; then
    echo -e "${YELLOW}找不到任何 IAM Role${NC}"
  else
    echo -e "${GREEN}找到以下 IAM Role:${NC}"
    echo ""
    printf "${CYAN}%-60s %-25s %-50s${NC}\n" "Role 名稱" "建立日期" "描述"
    echo "----------------------------------------------------------------------------------------------------------------------------"
    echo "${roles}" | while IFS=$'\t' read -r role_name create_date description; do
      # 格式化日期 (只顯示日期部分)
      local formatted_date="${create_date%%T*}"
      printf "%-60s %-25s %-50s\n" "${role_name}" "${formatted_date}" "${description:-N/A}"
    done
  fi
}

# 主程式
function main() {
  show_operation_menu
  
  local choice=""
  read -rp "請選擇操作選項 (1-${#OPERATION_OPTIONS[@]}): " choice
  
  case "${choice}" in
    1)
      list_iam_roles
      ;;
    *)
      echo -e "${RED}無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}${NC}"
      exit 1
      ;;
  esac
}

main
