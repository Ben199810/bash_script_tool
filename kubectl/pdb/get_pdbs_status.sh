#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/default.sh"

echo -e "${BLUE}=== PDB 狀態查詢器 ===${NC}"
echo ""

main(){
  ask_switch_context_and_namespace_interface
  ask_query_all_namespaces
  RESOURCE_TYPE="pdb"
  get_selected_kubernetes_resource
  display_pdb_details "$RESOURCE_ARRAY"
  echo -e "${BLUE}🎉 查詢完成！${NC}"
}

main