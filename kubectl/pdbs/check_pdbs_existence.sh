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
    RESOURCE_TYPE="pdb"
    get_selected_kubernetes_resource
    # 搜尋 PDB
    search_pdb "$RESOURCE_ARRAY"
    echo -e "${BLUE}🎉 搜尋完成！${NC}"
}

# 執行主程式
main

