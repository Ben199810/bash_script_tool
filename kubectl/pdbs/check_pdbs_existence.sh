#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/default.sh"

echo -e "${BLUE}=== PDB 存在檢查器 ===${NC}"
echo ""

# 主程式
main() {
    # 切換 Kubernetes context
    switch_context_interface
    # 輸入搜尋關鍵字
    prompts_search_keyword
    # 取得所有 PDB
    get_all_pdbs "$SEARCH_KEYWORD"
    # 搜尋 PDB
    search_pdb "$PDB_LIST"
    # 顯示 PDB 詳細資訊
    display_pdb_details "$MATCHING_PDBS"
    echo -e "${BLUE}🎉 搜尋完成！${NC}"
}

# 執行主程式
main

