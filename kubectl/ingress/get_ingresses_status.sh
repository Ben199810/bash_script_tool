#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  # 切換 Kubernetes context
  switch_context_interface
  # 詢問是否查詢所有命名空間
  ask_query_all_namespaces
  RESOURCE_TYPE="ingress"
  get_selected_kubernetes_resource
  display_ingress_details "$RESOURCE_ARRAY"
  echo -e "${BLUE}🎉 查詢完成！${NC}"
}

main