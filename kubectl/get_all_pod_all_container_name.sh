#!/bin/bash
source ../modules/default.sh

# 顯示當前 kubernetes 的 context
CURRENT_CONTEXTS=$(kubectl config current-context)
echo -e "${BLUE}Current Kubernetes contexts: $CURRENT_CONTEXTS${NC}"

# 顯示當前 kubernetes 的 namespace
CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
echo -e "${BLUE}Current Kubernetes namespace: $CURRENT_NAMESPACE${NC}"

# 查看 kubernetes 所有 Pod 的 Container Name
ALL_POD_NAME=$(kubectl get pods -o "name")
echo -e "All Pods: \n$ALL_POD_NAME"
for POD_NAME in $ALL_POD_NAME; do
  # 取得 Pod 的 Container Name
  CONTAINER_NAME=$(kubectl get $POD_NAME -o jsonpath='{.spec.containers[*].name}')
  # 取得 Pod 的 Container Image
  # CONTAINER_IMAGE=$(kubectl get $POD_NAME -o jsonpath='{.spec.containers[*].image}')
  echo -e "${BLUE}Pod: $POD_NAME \nContainer Name: $CONTAINER_NAME${NC}"
  # echo -e "${BLUE}Pod: $POD_NAME \nContainer Name: $CONTAINER_NAME \nContainer Image: $CONTAINER_IMAGE${NC}"
  if [ $CONTAINER_NAME == "app" ]; then
    echo -e "${RED}Container Name: $CONTAINER_NAME${NC}"
  fi
done
echo -e "${GREEN}All Pods and their Container Names displayed successfully.${NC}"