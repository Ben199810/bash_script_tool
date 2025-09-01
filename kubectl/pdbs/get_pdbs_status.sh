#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/default.sh"

echo -e "${BLUE}=== PDB 狀態查詢器 ===${NC}"
echo ""

main(){
  # 切換 Kubernetes context
  switch_context_interface
  # 取得所有 PDB
  get_all_pdbs "$SEARCH_KEYWORD"
  # 顯示 PDB 詳細資訊
  display_pdb_details "$PDB_LIST"
  echo -e "${BLUE}🎉 查詢完成！${NC}"
}

main