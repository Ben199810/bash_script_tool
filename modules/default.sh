# 字體顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
# 全域變數
SEARCH_KEYWORD=""
# 函數：請使用者輸入要搜尋的關鍵字
function prompts_search_keyword() {
    while [[ -z "$SEARCH_KEYWORD" ]]; do
        echo -en "${YELLOW}請輸入要搜尋的關鍵字: ${NC}"
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