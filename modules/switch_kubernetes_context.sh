#!/bin/bash
source ../modules/default.sh

CURRENT_CONTEXT
CURRENT_NAMESPACE

function current_context() {
  $CURRENT_CONTEXT=$(kubectl config current-context)
  echo -e "${BLUE}Current Kubernetes contexts: $CURRENT_CONTEXT${NC}"
}

function current_namespace() {
  $CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
  echo -e "${BLUE}Current Kubernetes namespace: $CURRENT_NAMESPACE${NC}"
}

function switch_context() {
  KUBE_CONTEXT=$1
  if [ -n "$KUBE_CONTEXT" ]; then
    kubectl config use-context "$KUBE_CONTEXT"
  else
    echo -e "${RED}No context selected. Exiting.${NC}"
    exit 1
  fi
}

function switch_namespace() {
  KUBE_NAMESPACE=$1
  if [ -n "$KUBE_NAMESPACE" ]; then
    # 去除前綴 "namespace/"
    KUBE_NAMESPACE=${KUBE_NAMESPACE#namespace/}
    kubectl config set-context --current --namespace="$KUBE_NAMESPACE"
  else
    echo -e "${RED}No namespace selected. Exiting.${NC}"
    exit 1
  fi
}

switch_context_interface(){
  current_context
  current_namespace

  read -p "你想要切換 Kubernetes Context 嗎? (y/n): " SWITCH_CONTEXT
  if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
    KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
    switch_context $KUBE_CONTEXT
    KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
    switch_namespace $KUBE_NAMESPACE
  else
    echo -e "${YELLOW}Skipping context switch.${NC}"
  fi

  current_context
  current_namespace
}