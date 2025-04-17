#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh.sh

# 使用 fzf 選擇 deployment
DEPLOYMENT_NAME=$(kubectl get deployment -o name | fzf)
if [ -z "$DEPLOYMENT_NAME" ]; then
  echo -e "${RED}No deployment selected.${NC}"
  exit 1
fi
echo -e "${BLUE}Selected deployment: $DEPLOYMENT_NAME${NC}"

# 查看 deployment 的 container name
CONTAINER_NAME=$(kubectl get $DEPLOYMENT_NAME -o jsonpath='{.spec.template.spec.containers[*].name}')
echo -e "${GREEN}Container Name: $CONTAINER_NAME${NC}"
# 查看 deployment 的 container image
CONTAINER_IMAGE=$(kubectl get $DEPLOYMENT_NAME -o jsonpath='{.spec.template.spec.containers[*].image}')
echo -e "${GREEN}Container Image: $CONTAINER_IMAGE${NC}"