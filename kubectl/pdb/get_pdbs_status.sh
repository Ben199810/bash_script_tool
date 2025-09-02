#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/default.sh"

echo -e "${BLUE}=== PDB 狀態查詢器 ===${NC}"
echo ""

main(){
  # 切換 Kubernetes context
  switch_context_interface
  # 詢問是否查詢所有命名空間
  ask_query_all_namespaces
  # 取得所有 PDB
  RESOURCE_TYPE="pdb"
  get_selected_kubernetes_resource
  # 顯示 PDB 詳細資訊
  display_pdb_details "$RESOURCE_ARRAY"
  echo -e "${BLUE}🎉 查詢完成！${NC}"
}

main