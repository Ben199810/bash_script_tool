#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/default.sh"

echo -e "${BLUE}=== PDB 存在檢查器 ===${NC}"
echo ""

# 主程式
main() {
    ask_switch_context_interface
    prompts_search_keyword
    RESOURCE_TYPE="pdb"
    get_selected_kubernetes_resource
    search_pdb "$RESOURCE_ARRAY"
    echo -e "${BLUE}🎉 搜尋完成！${NC}"
}

# 執行主程式
main

