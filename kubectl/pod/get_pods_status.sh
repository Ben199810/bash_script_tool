#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  ask_switch_context_and_namespace_interface
  ask_query_all_namespaces
  RESOURCE_TYPE="pod"
  get_selected_kubernetes_resource
  display_pod_details "$RESOURCE_ARRAY"
  echo -e "${BLUE}🎉 查詢完成！${NC}"
}

main