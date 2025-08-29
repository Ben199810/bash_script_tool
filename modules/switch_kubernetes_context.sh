#!/bin/bash

declare CURRENT_CONTEXT=""
declare CURRENT_NAMESPACE=""

function get_current_context() {
  CURRENT_CONTEXT=$(kubectl config current-context)
  echo -e "${BLUE}當前本機環境 Kubernetes contexts: $CURRENT_CONTEXT${NC}"
}

function get_current_namespace() {
  CURRENT_NAMESPACE=$(kubectl config view --minify -o json | jq -r '.contexts[].context.namespace')
  echo -e "${BLUE}當前本機環境 Kubernetes namespace: $CURRENT_NAMESPACE${NC}"
}

function switch_context() {
  CONTEXT=$1
  if [ -n "$CONTEXT" ]; then
    kubectl config use-context "$CONTEXT"
  else
    echo -e "${RED}未選擇 Kubernetes Context，退出。${NC}"
    exit 1
  fi
}

function switch_namespace() {
  NAMESPACE=$1
  if [ -n "$NAMESPACE" ]; then
    # 去除前綴 "namespace/"
    NAMESPACE=${NAMESPACE#namespace/}
    kubectl config set-context --current --namespace="$NAMESPACE"
  else
    echo -e "${RED}未選擇命名空間，退出。${NC}"
    exit 1
  fi
}

# 實作切換 Kubernetes Context 和 Namespace 的介面流程
function switch_context_interface(){
  get_current_context
  read -p "你想要切換 Kubernetes Context 嗎? (y/n): " SWITCH_CONTEXT
  if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
    CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
    switch_context $CONTEXT
    echo -e "${GREEN}已切換到 Kubernetes Context: $CONTEXT${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Context。${NC}"
    echo ""
  fi

  get_current_namespace
  read -p "你想要切換 Kubernetes Namespace 嗎? (y/n): " SWITCH_NAMESPACE
  if [[ "$SWITCH_NAMESPACE" =~ ^[Yy]$ ]]; then
    NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
    switch_namespace $NAMESPACE
    echo -e "${GREEN}已切換到 Kubernetes Namespace: $NAMESPACE${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Namespace。${NC}"
    echo ""
  fi

  get_current_context
  get_current_namespace
  echo ""
}