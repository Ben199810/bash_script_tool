#!/bin/bash
source ../modules/default.sh
source ../modules/switch_kubernetes_context.sh

# 檢查所有 deployments 內所有的 container 使用的 image 名稱
# 如果有使用的 image 名稱開頭是 gcr.io 則顯示該 container 的資訊

DEPLOYMENTS=$(kubectl get deployment --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
if [ -z "$DEPLOYMENTS" ]; then
  echo -e "${RED}No deployments found.${NC}"
  exit 1
fi

for DEPLOYMENT in $DEPLOYMENTS; do
  CONTAINER_IMAGE=$(kubectl get deployment $DEPLOYMENT --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
  if [[ "$CONTAINER_IMAGE" == gcr.io* ]]; then
    echo -e "${BLUE}Selected deployment: $DEPLOYMENT${NC}"
    echo -e "${GREEN}Container Image: $CONTAINER_IMAGE${NC}"
  fi
done