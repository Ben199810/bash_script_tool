#!/bin/bash
source ../../../modules/default.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "查詢區域 S3 Bucket 列表"
  "Bucket 之間同步資料 (同一個 Account)"
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

# Bucket 之間同步資料
function sync_s3_buckets() {
  local source_region=""
  local source_bucket=""
  local target_region=""
  local target_bucket=""
  local source_path=""
  local target_path=""
  
  echo -e "${CYAN}=== S3 Bucket 同步 ===${NC}"
  echo ""
  
  # 輸入來源 Bucket 資訊
  read -rp "請輸入來源 Bucket 區域 (預設: ap-southeast-1): " source_region
  source_region="${source_region:-ap-southeast-1}"
  
  read -rp "請輸入來源 Bucket 名稱: " source_bucket
  if [[ -z "${source_bucket}" ]]; then
    echo -e "${RED}來源 Bucket 名稱不能為空${NC}"
    exit 1
  fi
  
  read -rp "請輸入來源路徑 (預設: / 整個 Bucket，例如: /folder/): " source_path
  source_path="${source_path:-/}"
  
  # 輸入目標 Bucket 資訊
  read -rp "請輸入目標 Bucket 區域 (預設: ap-southeast-1): " target_region
  target_region="${target_region:-ap-southeast-1}"
  
  read -rp "請輸入目標 Bucket 名稱: " target_bucket
  if [[ -z "${target_bucket}" ]]; then
    echo -e "${RED}目標 Bucket 名稱不能為空${NC}"
    exit 1
  fi
  
  read -rp "請輸入目標路徑 (預設: / 整個 Bucket，例如: /folder/): " target_path
  target_path="${target_path:-/}"
  
  # 確認同步操作
  echo ""
  echo -e "${YELLOW}=== 同步資訊確認 ===${NC}"
  echo -e "來源: ${GREEN}s3://${source_bucket}${source_path}${NC} (${source_region})"
  echo -e "目標: ${GREEN}s3://${target_bucket}${target_path}${NC} (${target_region})"
  echo ""
  
  read -rp "確定要執行同步嗎？(y/N): " confirm
  if [[ "${confirm}" != "y" ]] && [[ "${confirm}" != "Y" ]]; then
    echo -e "${YELLOW}已取消同步操作${NC}"
    exit 0
  fi
  
  # 執行同步
  echo ""
  echo -e "${BLUE}開始同步資料...${NC}"
  
  local source_uri="s3://${source_bucket}${source_path}"
  local target_uri="s3://${target_bucket}${target_path}"
  
  # 使用 aws s3 sync 指令
  aws s3 sync "${source_uri}" "${target_uri}" --region "${target_region}" --source-region "${source_region}"
  
  if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓ 同步完成${NC}"
  else
    echo ""
    echo -e "${RED}✗ 同步失敗，請檢查錯誤訊息${NC}"
    exit 1
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
    2)
      sync_s3_buckets
      ;;
    *)
      echo -e "${RED}無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}${NC}"
      exit 1
      ;;
  esac
}

main

