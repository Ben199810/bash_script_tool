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
# 請使用者輸入要搜尋的關鍵字
function prompts_search_keyword() {
  while [[ -z "$SEARCH_KEYWORD" ]]; do
    read -rp "請輸入要搜尋的關鍵字: " SEARCH_KEYWORD
    if [[ -z "$SEARCH_KEYWORD" ]]; then
      echo -e "${RED}❌ 關鍵字不能為空，請重新輸入${NC}"
    fi
  done
  echo -e "${GREEN}✅ 搜尋關鍵字: $SEARCH_KEYWORD${NC}"
}

# 安裝 brew 作為套件管理工具。
function check_and_install_brew() {
  if ! brew -v &> /dev/null; then
    echo -e "${RED}❌ brew 未安裝，請先安裝 brew。${NC}"
    echo -e "${YELLOW}🔄 開始自動安裝 brew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # 再次檢查是否安裝成功
    if ! brew -v &> /dev/null; then
      echo -e "${RED}❌ brew 安裝失敗，請手動安裝。${NC}"
      echo -e "${YELLOW}請參考官網 👉 https://brew.sh${NC}"
      exit 1
    else
      echo -e "${GREEN}✅ brew 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}⭐ brew 已安裝。${NC}"
  fi
}

# npm 相關的套件安裝。
function npm_install_kit() {
  local KIT_ARRAY=${1:-""}
  # 檢查 Node.js 是否安裝
  if ! node -v &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安裝，請先安裝 Node.js。${NC}"
    echo -e "${YELLOW}🔄 開始自動安裝 Node.js...${NC}\n"
    brew install node
  fi
  if [ -z "$KIT_ARRAY" ]; then
    echo -e "${RED}❌ 請提供要安裝的 npm 套件清單。${NC}\n"
  else
    echo -e "${YELLOW}🔄 開始安裝 npm 套件...${NC}\n"
    for kit in ${KIT_ARRAY[@]}; do
      echo -e "${YELLOW}🔄 正在安裝 ${kit}...${NC}"
      npm install -g "$kit". # 全域安裝
      # 檢查安裝是否成功
      if ! npm list -g --depth=0 | grep -q "$kit@"; then
        echo -e "${RED}❌ ${kit} 安裝失敗。${NC}\n"
        exit 1
      fi
    done
  fi
  echo -e "${GREEN}✅ npm 套件安裝完成。${NC}\n"
}