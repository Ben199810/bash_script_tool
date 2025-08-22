#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

# 全域變數
SEARCH_KEYWORD=""

# 函數：請使用者輸入要搜尋的關鍵字
prompts_search_keyword() {
    echo -e "${BLUE}=== PDB 存在檢查器 ===${NC}"
    echo ""
    
    while [[ -z "$SEARCH_KEYWORD" ]]; do
        echo -en "${YELLOW}請輸入要搜尋的 PDB 關鍵字: ${NC}"
        read -r SEARCH_KEYWORD
        
        if [[ -z "$SEARCH_KEYWORD" ]]; then
            echo -e "${RED}❌ 關鍵字不能為空，請重新輸入${NC}"
            echo ""
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ 搜尋關鍵字: $SEARCH_KEYWORD${NC}"
    echo ""
}

# 函數：搜尋 PDB
search_pdb() {
    local search_keyword="$1"
    
    echo -e "${BLUE}🔍 搜尋包含 '$search_keyword' 的 PDB...${NC}"
    echo ""
    
    # 取得所有 PDB
    local pdb_list
    pdb_list=$(kubectl get pdb --all-namespaces --no-headers 2>/dev/null)
    
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ 無法取得 PDB 列表，請檢查 kubectl 連線${NC}"
        return 1
    fi
    
    if [[ -z "$pdb_list" ]]; then
        echo -e "${YELLOW}⚠️  叢集中沒有找到任何 PDB${NC}"
        return 0
    fi
    
    # 搜尋符合關鍵字的 PDB
    local matching_pdbs
    matching_pdbs=$(echo "$pdb_list" | grep -i "$search_keyword")
    
    if [[ -z "$matching_pdbs" ]]; then
        echo -e "${YELLOW}⚠️  沒有找到包含 '$search_keyword' 的 PDB${NC}"
        echo ""
        echo -e "${BLUE}💡 所有可用的 PDB:${NC}"
        echo "$pdb_list" | awk '{printf "   %s (namespace: %s)\n", $2, $1}'
    else
        echo -e "${GREEN}✅ 找到 $(echo "$matching_pdbs" | wc -l) 個符合的 PDB:${NC}"
        echo ""
        echo "$matching_pdbs" | while read -r line; do
            local namespace=$(echo "$line" | awk '{print $1}')
            local name=$(echo "$line" | awk '{print $2}')
            local min_available=$(echo "$line" | awk '{print $3}')
            local max_unavailable=$(echo "$line" | awk '{print $4}')
            local allowed_disruptions=$(echo "$line" | awk '{print $5}')
            local age=$(echo "$line" | awk '{print $6}')
            
            echo -e "${GREEN}📋 PDB 名稱:${NC} $name"
            echo -e "${BLUE}   命名空間:${NC} $namespace"
            echo -e "${BLUE}   最小可用:${NC} $min_available"
            echo -e "${BLUE}   最大不可用:${NC} $max_unavailable"
            echo -e "${BLUE}   允許中斷:${NC} $allowed_disruptions"
            echo -e "${BLUE}   建立時間:${NC} $age"
            echo ""
        done
    fi
}

switch_context_interface

# 主程式
main() {
    # 取得搜尋關鍵字
    prompts_search_keyword
    
    # 搜尋 PDB
    search_pdb "$SEARCH_KEYWORD"
    
    echo -e "${BLUE}🎉 搜尋完成！${NC}"
}

# 執行主程式
main

