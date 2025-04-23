#!/bin/bash
source ../modules/default.sh
source ../modules/kubectl_operate.sh

current_context
current_namespace

read -p "Do you want to switch Kubernetes Context? (y/n): " SWITCH_CONTEXT
if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
  # 使用 fzf 選擇 Kubernetes Context
  KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
  switch_context $KUBE_CONTEXT
  # 使用 fzf 選擇 Kubernetes Namespace
  KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
  switch_namespace $KUBE_NAMESPACE
else
  echo -e "${YELLOW}Skipping context switch.${NC}"
fi

current_context
current_namespace