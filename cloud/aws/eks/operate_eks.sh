#!/bin/bash
source ../../../modules/default.sh

# 操作選項陣列
OPERATION_OPTIONS=(
  "本機電腦連線 EKS 區域叢集"
  "查詢 AWS 帳號中 EKS 區域叢集"
)

# 顯示操作選項並讓使用者選擇
function show_operation_menu() {
  echo -e "${CYAN}=== EKS 操作選單 ===${NC}"
  for i in "${!OPERATION_OPTIONS[@]}"; do
    printf "${YELLOW}%d)${NC} %s\n" $((i + 1)) "${OPERATION_OPTIONS[$i]}"
  done
  echo ""
}

# 連線到 EKS 叢集
function connect_to_eks_cluster() {
  local cluster_name=""
  local aws_region=""
  local alias_name=""
  local use_alias=""
  
  read -rp "請輸入 EKS 叢集名稱: " cluster_name
  read -rp "請輸入 AWS 區域 (預設: ap-southeast-1): " aws_region
  # AWS_REGION 預設新加坡
  aws_region="${aws_region:-ap-southeast-1}"
  
  # 詢問是否要設定 alias
  echo ""
  read -rp "是否要為此 EKS 設定自訂 alias 名稱? (y/N): " use_alias
  
  if [[ "${use_alias}" =~ ^[Yy]$ ]]; then
    read -rp "請輸入自訂的 alias 名稱: " alias_name
    
    if [[ -n "${alias_name}" ]]; then
      echo -e "${BLUE}正在連接到 EKS 叢集 ${cluster_name} 位於區域 ${aws_region},並設定 alias 為 ${alias_name}...${NC}"
      aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}" --alias "${alias_name}"
    else
      echo -e "${YELLOW}未輸入 alias 名稱,使用預設設定${NC}"
      echo -e "${BLUE}正在連接到 EKS 叢集 ${cluster_name} 位於區域 ${aws_region}...${NC}"
      aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}"
    fi
  else
    echo -e "${BLUE}正在連接到 EKS 叢集 ${cluster_name} 位於區域 ${aws_region}...${NC}"
    aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}"
  fi
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}無法連接到 EKS 叢集 ${cluster_name}。請檢查叢集名稱和區域是否正確,並確保您已配置 AWS CLI。${NC}"
    exit 1
  else
    if [[ -n "${alias_name}" ]]; then
      echo -e "${GREEN}已成功連接到 EKS 叢集 ${cluster_name},context 名稱為: ${alias_name}${NC}"
    else
      echo -e "${GREEN}已成功連接到 EKS 叢集 ${cluster_name}${NC}"
    fi
  fi
}

# 查詢 AWS 帳號中的 EKS 叢集
function list_eks_clusters() {
  local aws_region=""
  
  read -rp "請輸入 AWS 區域 (預設: ap-southeast-1): " aws_region
  # AWS_REGION 預設新加坡
  aws_region="${aws_region:-ap-southeast-1}"
  
  echo -e "${BLUE}正在查詢區域 ${aws_region} 中的 EKS 叢集...${NC}"
  local clusters
  clusters=$(aws eks list-clusters --region "${aws_region}" --output json)
  
  if [[ $? -ne 0 ]]; then
    echo -e "${RED}無法查詢 EKS 叢集。請確保您已配置 AWS CLI。${NC}"
    exit 1
  fi
  
  local cluster_names
  cluster_names=$(echo "${clusters}" | jq -r '.clusters[]' 2>/dev/null)
  
  if [[ -z "${cluster_names}" ]]; then
    echo -e "${YELLOW}在區域 ${aws_region} 中找不到任何 EKS 叢集${NC}"
  else
    echo -e "${GREEN}找到以下 EKS 叢集:${NC}"
    echo "${cluster_names}" | while read -r cluster; do
      echo -e "${CYAN}  - ${cluster}${NC}"
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
      connect_to_eks_cluster
      ;;
    2)
      list_eks_clusters
      ;;
    *)
      echo -e "${RED}無效的選項,請選擇 1-${#OPERATION_OPTIONS[@]}${NC}"
      exit 1
      ;;
  esac
}

main