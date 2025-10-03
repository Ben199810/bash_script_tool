#!/bin/bash
source ../../../modules/default.sh

read -p "請輸入 EKS 叢集名稱: " CLUSTER_NAME
read -p "請輸入 AWS 區域 (預設: ap-southeast-1): " AWS_REGION
# AWS_REGION 預設新加坡
AWS_REGION=${AWS_REGION:-ap-southeast-1}

echo -e "${BLUE}正在連接到 EKS 叢集 $CLUSTER_NAME 位於區域 $AWS_REGION...${NC}"
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME

if [ $? -ne 0 ]; then
  echo -e "${RED}無法連接到 EKS 叢集 $CLUSTER_NAME。請檢查叢集名稱和區域是否正確，並確保您已配置 AWS CLI。${NC}"
  exit 1
else
  echo -e "${GREEN}已成功連接到 EKS 叢集 $CLUSTER_NAME${NC}"
fi