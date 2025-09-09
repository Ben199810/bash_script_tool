#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  get_all_contexts
  ask_query_all_namespaces
  for CONTEXT in "${KUBERNETES_CONTEXTS[@]}"; do
    echo -e "${BLUE}當前尋找的 Context: ${CONTEXT}${NC}"
    local NAMESPACE_OPTION=$(get_namespace_option)
    local KUBE_CONTEXT_OPTION="--context=${CONTEXT}"

    find_loadbalancer_services
    echo ""
  done
  echo -e "${GREEN}=== 已完成所有叢集的 LoadBalancer 服務搜尋 ===${NC}"
}

main
