#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  get_common_contexts
  ask_query_all_namespaces
  prompts_search_keyword
  for KUBE_CONTEXT in "${KUBERNETES_CONTEXTS[@]}"; do
    echo -e "${BLUE}當前尋找的 Context: ${KUBE_CONTEXT}${NC}"
    RESOURCE_TYPE="service"
    get_selected_kubernetes_resource
    search_service "$RESOURCE_ARRAY"
    echo -e "${BLUE}🎉 在 Context ${KUBE_CONTEXT} 中的搜尋完成！${NC}\n"
  done
  echo -e "${GREEN}✅ 已完成所有叢集的 LoadBalancer 服務搜尋${NC}"
}

main