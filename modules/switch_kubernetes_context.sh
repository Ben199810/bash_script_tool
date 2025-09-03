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
  TARGET_CONTEXT=$1
  if [ -n "$TARGET_CONTEXT" ]; then
    kubectl config use-context "$TARGET_CONTEXT"
  else
    echo -e "${RED}未選擇 Kubernetes Context，退出。${NC}"
    exit 1
  fi
}

function switch_namespace(){
  TARGET_NAMESPACE=$1
  if [ -n "$TARGET_NAMESPACE" ]; then
    # 去除前綴 "namespace/"
    TARGET_NAMESPACE=${TARGET_NAMESPACE#namespace/}
    kubectl config set-context --current --namespace="$TARGET_NAMESPACE"
  else
    echo -e "${RED}未選擇命名空間，退出。${NC}"
    exit 1
  fi
}

# 實作切換 Kubernetes Context 和 Namespace 的介面流程
function ask_switch_context_and_namespace_interface(){
  get_current_context
  read -p "你想要切換 Kubernetes Context 嗎? (y/n): " SWITCH_CONTEXT
  if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
    local SELECT_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
    switch_context $SELECT_CONTEXT
    echo -e "${GREEN}已切換到 Kubernetes Context: $SELECT_CONTEXT${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Context。${NC}"
    echo ""
  fi

  get_current_namespace
  read -p "你想要切換 Kubernetes Namespace 嗎? (y/n): " SWITCH_NAMESPACE
  if [[ "$SWITCH_NAMESPACE" =~ ^[Yy]$ ]]; then
    local SELECT_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
    switch_namespace $SELECT_NAMESPACE
    echo -e "${GREEN}已切換到 Kubernetes Namespace: $SELECT_NAMESPACE${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Namespace。${NC}"
    echo ""
  fi

  get_current_context
  get_current_namespace
  echo ""
}

# 實作切換 Kubernetes Context 的介面流程
function ask_switch_context_interface() {
  get_current_context
  read -p "你想要切換 Kubernetes Context 嗎? (y/n): " SWITCH_CONTEXT
  if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
    local SELECT_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
    switch_context $SELECT_CONTEXT
    echo -e "${GREEN}已切換到 Kubernetes Context: $SELECT_CONTEXT${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Context。${NC}"
    echo ""
  fi
  get_current_context
  echo ""
}

# 實作切換 Kubernetes Namespace 的介面流程
function ask_switch_namespace_interface() {
  get_current_namespace
  read -p "你想要切換 Kubernetes Namespace 嗎? (y/n): " SWITCH_NAMESPACE
  if [[ "$SWITCH_NAMESPACE" =~ ^[Yy]$ ]]; then
    local SELECT_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
    switch_namespace $SELECT_NAMESPACE
    echo -e "${GREEN}已切換到 Kubernetes Namespace: $SELECT_NAMESPACE${NC}"
    echo ""
  else
    echo -e "${YELLOW}跳過切換 Kubernetes Namespace。${NC}"
    echo ""
  fi
  get_current_namespace
  echo ""
}