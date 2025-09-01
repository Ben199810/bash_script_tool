#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

echo -e "${BLUE}=== PDB 存在檢查器 ===${NC}"
echo ""

prompts_search_keyword

# 函數：搜尋 PDB
search_pdb() {
    local SEARCH_KEYWORD="$1"
    
    echo -e "${BLUE}🔍 搜尋包含 '$SEARCH_KEYWORD' 的 PDB...${NC}"
    echo ""
    
    ask_query_all_namespaces
    local NAMESPACE_OPTION=$(get_namespace_option)

    # 取得所有 PDB
    local PDB_LIST=$(kubectl get pdb $NAMESPACE_OPTION --no-headers 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ 無法取得 PDB 列表，請檢查 kubectl 連線${NC}"
        return 1
    fi
    
    if [[ -z "$PDB_LIST" ]]; then
        echo -e "${YELLOW}⚠️  叢集中沒有找到任何 PDB${NC}"
        return 0
    fi
    
    # 搜尋符合關鍵字的 PDB
    local MATCHING_PDBS
    MATCHING_PDBS=$(echo "$PDB_LIST" | grep -i "$SEARCH_KEYWORD")
    
    if [[ -z "$MATCHING_PDBS" ]]; then
        echo -e "${YELLOW}⚠️  沒有找到包含 '$SEARCH_KEYWORD' 的 PDB${NC}"
        echo ""
        echo -e "${BLUE}💡 所有可用的 PDB:${NC}"
        echo "$PDB_LIST" | awk '{printf "   %s (namespace: %s)\n", $2, $1}'
    else
        echo -e "${GREEN}✅ 找到 $(echo "$MATCHING_PDBS" | wc -l) 個符合的 PDB:${NC}"
        echo ""
        echo "$MATCHING_PDBS" | while read -r LINE; do
        echo $LINE
            local NAMESPACE=$(echo "$LINE" | awk '{print $1}')
            local NAME=$(echo "$LINE" | awk '{print $2}')
            local MIN_AVAILABLE=$(echo "$LINE" | awk '{print $3}')
            local MAX_UNAVAILABLE=$(echo "$LINE" | awk '{print $4}')
            local ALLOWED_DISRUPTIONS=$(echo "$LINE" | awk '{print $5}')
            local AGE=$(echo "$LINE" | awk '{print $6}')
            
            echo -e "${GREEN}📋 PDB 名稱:${NC} $NAME"
            echo -e "${BLUE}   命名空間:${NC} $NAMESPACE"
            echo -e "${BLUE}   最小可用:${NC} $MIN_AVAILABLE"
            echo -e "${BLUE}   最大不可用:${NC} $MAX_UNAVAILABLE"
            echo -e "${BLUE}   允許中斷:${NC} $ALLOWED_DISRUPTIONS"
            echo -e "${BLUE}   建立時間:${NC} $AGE"
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

