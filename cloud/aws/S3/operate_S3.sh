#!/bin/bash
source ../../../modules/default.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "查詢區域 S3 Bucket 列表"
)

# 顯示操作選項並讓使用者選擇
function show_operation_menu() {
  echo -e "${CYAN}=== S3 操作選單 ===${NC}"
  for i in "${!OPERATION_OPTIONS[@]}"; do
    printf "${YELLOW}%d)${NC} %s\n" $((i + 1)) "${OPERATION_OPTIONS[$i]}"
  done
  echo ""
}

# 查詢 S3 Bucket 列表
function list_s3_buckets() {
  local aws_region=""
  
  read -rp "請輸入 AWS 區域 (預設: ap-southeast-1，輸入 'all' 查詢所有區域): " aws_region
  # AWS_REGION 預設新加坡
  aws_region="${aws_region:-ap-southeast-1}"
  
  echo -e "${BLUE}正在查詢 S3 Bucket 列表...${NC}"
  
  local buckets
  buckets=$(aws s3api list-buckets --query "Buckets[*].[Name, CreationDate]" --output text 2>&1)
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}無法查詢 S3 Bucket。請確保您已配置 AWS CLI 並擁有適當的權限。${NC}"
    exit 1
  fi
  
  if [[ -z "${buckets}" ]]; then
    echo -e "${YELLOW}找不到任何 S3 Bucket${NC}"
  else
    echo -e "${GREEN}找到以下 S3 Bucket:${NC}"
    echo ""
    printf "${CYAN}%-60s %-25s %-20s${NC}\n" "Bucket 名稱" "建立日期" "區域"
    echo "------------------------------------------------------------------------------------------------------------------------------"
    
    echo "${buckets}" | while IFS=$'\t' read -r bucket_name creation_date; do
      # 查詢 Bucket 所在區域
      local bucket_region
      bucket_region=$(aws s3api get-bucket-location --bucket "${bucket_name}" --output text 2>/dev/null)
      
      # AWS 預設 us-east-1 回傳 None
      if [[ "${bucket_region}" == "None" ]]; then
        bucket_region="us-east-1"
      fi
      
      # 如果指定了區域且不是 'all'，則只顯示該區域的 Bucket
      if [[ "${aws_region}" == "all" ]] || [[ "${bucket_region}" == "${aws_region}" ]]; then
        # 格式化日期 (只顯示日期部分)
        local formatted_date="${creation_date%%T*}"
        printf "%-60s %-25s %-20s\n" "${bucket_name}" "${formatted_date}" "${bucket_region}"
      fi
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
      list_s3_buckets
      ;;
    *)
      echo -e "${RED}無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}${NC}"
      exit 1
      ;;
  esac
}

main

