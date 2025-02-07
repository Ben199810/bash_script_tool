check_brew() {
  # 檢查是否安裝 brew
  if ! brew -v &> /dev/null; then
    echo -e "${RED}brew 未安裝，請先安裝 brew。${NC}"

    # 安裝 brew
    echo -e "${YELLOW}開始自動安裝 brew...${NC}"
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

    # 再次檢查是否安裝成功
    if ! brew -v &> /dev/null; then
      echo -e "${RED}brew 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}brew 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}brew 已安裝。${NC}"
  fi
}

check_kubectl() {
  # 檢查是否安裝 kubectl
  if ! kubectl version --client &> /dev/null; then
    echo -e "${RED}kubectl 未安裝，請先安裝 kubectl。${NC}"

    # 安裝 kubectl
    echo -e "${YELLOW}開始自動安裝 kubectl...${NC}"
    brew install kubectl

    # 再次檢查是否安裝成功
    if ! kubectl version &> /dev/null; then
      echo -e "${RED}kubectl 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}kubectl 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}kubectl 已安裝。${NC}"
  fi
}

check_helm() {
  # 檢查是否安裝 helm
  if ! helm version &> /dev/null; then
    echo -e "${RED}helm 未安裝，請先安裝 helm。${NC}"

    # 安裝 helm
    echo -e "${YELLOW}開始自動安裝 helm...${NC}"
    brew install helm

    # 再次檢查是否安裝成功
    if ! helm version &> /dev/null; then
      echo -e "${RED}helm 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}helm 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}helm 已安裝。${NC}"
  fi
}

