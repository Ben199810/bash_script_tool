#!/bin/bash

# 匯入 modules/default.sh 模組
source ../modules/default.sh
# 匯入 modules/kubecontext_list.sh 模組
source ../modules/kubecontext_list.sh

# 檢查所有 midori 環境的 namespace 是否有 monitoring namespace
check_midori_environment_namespace() {
  for context in "${midori_environment[@]}"; do
    echo "Checking namespace in context: $context"
    namespaces_exist=$(kubectl get namespaces --context "$context" -o 'custom-columns=NAME:.metadata.name' --no-headers)
    if [[ -z "$namespaces_exist" ]]; then
      echo "No namespaces found in context: $context"
      continue
    fi
    # 檢查是否有 monitoring namespace
    if echo "$namespaces_exist" | grep -q "monitoring"; then
      echo -e "${RED}Namespace 'monitoring' exists in context: $context${NC}"
    else
      echo -e "${BLUE}Namespace 'monitoring' does not exist in context: $context${NC}"
    fi
  done
}

# 檢查所有 midori 環境的 pod 名稱是否有包含 prometheus
check_midori_environment_pod() {
  for context in "${midori_environment[@]}"; do
    echo "Checking pods in context: $context"
    pods_exist=$(kubectl get pods -A --context "$context" -o 'custom-columns=NAME:.metadata.name' --no-headers)
    if [[ -z "$pods_exist" ]]; then
      echo "No pods found in context: $context"
      continue
    fi
    # 檢查是否有 pod 名稱包含 prometheus
    if echo "$pods_exist" | grep -q "prometheus"; then
      echo -e "${RED}Pod with 'prometheus' exists in context: $context${NC}"
    else
      echo -e "${BLUE}Pod with 'prometheus' does not exist in context: $context${NC}"
    fi
  done
}

check_midori_environment_namespace
check_midori_environment_pod