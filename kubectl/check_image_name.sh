#!/bin/bash
source ../modules/default.sh
source ../modules/switch_kubernetes_context.sh

# images 空陣列儲存所有的 image 名稱
images=()

# 檢查所有 deployments 內所有的 container 使用的 image 名稱
# 如果有使用的 image 名稱開頭是 gcr.io 則顯示該 container 的資訊

DEPLOYMENTS=$(kubectl get deployment --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
if [ -z "$DEPLOYMENTS" ]; then
  echo -e "${RED}No deployments found.${NC}"
  exit 1
fi

for DEPLOYMENT in $DEPLOYMENTS; do
  echo -e "${BLUE}Selected deployment: $DEPLOYMENT${NC}"
  CONTAINER_IMAGES=$(kubectl get deployment $DEPLOYMENT --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
  for CONTAINER_IMAGE in $CONTAINER_IMAGES; do
    if [[ "$CONTAINER_IMAGE" == gcr.io/rd6-project/* ]]; then
      echo -e "${GREEN}Container Image: $CONTAINER_IMAGE${NC}"
      # 將 image 名稱加入 images 陣列
      images+=("$CONTAINER_IMAGE")
    fi
  done
done