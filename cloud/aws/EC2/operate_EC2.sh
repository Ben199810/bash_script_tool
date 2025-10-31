#!/bin/bash
source ../../../modules/default.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "查詢運行中的 EC2 區域實例"
)

# 顯示操作選項並讓使用者選擇
function show_operation_menu() {
  echo -e "${CYAN}=== EC2 操作選單 ===${NC}"
  for i in "${!OPERATION_OPTIONS[@]}"; do
    printf "${YELLOW}%d)${NC} %s\n" $((i + 1)) "${OPERATION_OPTIONS[$i]}"
  done
  echo ""
}

# 查詢運行中的 EC2 實例
function list_running_instances() {
  local aws_region=""
  
  read -rp "請輸入 AWS 區域 (預設: ap-southeast-1): " aws_region
  # AWS_REGION 預設新加坡
  aws_region="${aws_region:-ap-southeast-1}"
  
  echo -e "${BLUE}正在查詢區域 ${aws_region} 中運行的 EC2 實例...${NC}"
  
  local instances
  instances=$(aws ec2 describe-instances --region "${aws_region}" \
    --filter "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value | [0], InstanceId, InstanceType, PrivateIpAddress, Placement.AvailabilityZone]" \
    --output text)
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}無法查詢 EC2 實例。請確保您已配置 AWS CLI。${NC}"
    exit 1
  fi
  
  if [[ -z "${instances}" ]]; then
    echo -e "${YELLOW}在區域 ${aws_region} 中找不到任何運行中的 EC2 實例${NC}"
  else
    echo -e "${GREEN}找到以下運行中的 EC2 實例:${NC}"
    echo ""
    printf "${CYAN}%-40s %-20s %-15s %-15s %-20s${NC}\n" "名稱" "實例 ID" "實例類型" "私有 IP" "可用區"
    echo "------------------------------------------------------------------------------------------------------------------------------"
    echo "${instances}" | while read -r name instance_id instance_type private_ip az; do
      printf "%-40s %-20s %-15s %-15s %-20s\n" "${name:-N/A}" "${instance_id}" "${instance_type}" "${private_ip}" "${az}"
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
      list_running_instances
      ;;
    *)
      echo -e "${RED}無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}${NC}"
      exit 1
      ;;
  esac
}

main