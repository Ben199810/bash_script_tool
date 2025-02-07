check_kubectl() {
  # 檢查是否安裝 kubectl
  if ! kubectl version --client &> /dev/null; then
    echo -e "${RED}kubectl 未安裝，請先安裝 kubectl。${NC}"

    # 安裝 kubectl
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