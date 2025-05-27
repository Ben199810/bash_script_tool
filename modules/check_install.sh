check_brew() {
  # 檢查是否安裝 brew
  if ! brew -v &> /dev/null; then
    echo -e "${RED}brew 未安裝，請先安裝 brew。${NC}"

    # 安裝 brew
    echo -e "${YELLOW}開始自動安裝 brew...${NC}"
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

check_iterm2() {
  # 檢查是否安裝 iterm2
  if ! open -a iTerm &> /dev/null; then
    echo -e "${RED}iTerm2 未安裝，請先安裝 iTerm2。${NC}"
    
    # 安裝 iterm2
    echo -e "${YELLOW}開始自動安裝 iTerm2...${NC}"
    brew install iterm2

    # 再次檢查是否安裝成功
    if ! open -a iTerm &> /dev/null; then
      echo -e "${RED}iTerm2 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}iTerm2 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}iTerm2 已安裝。${NC}"
  fi
}

check_zsh() {
  # 檢查是否安裝 zsh
  if ! zsh --version &> /dev/null; then
    echo -e "${RED}zsh 未安裝，請先安裝 zsh。${NC}"

    # 安裝 zsh
    echo -e "${YELLOW}開始自動安裝 zsh...${NC}"
    brew install zsh

    # 安裝 oh-my-zsh
    echo -e "${YELLOW}開始自動安裝 oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # 再次檢查是否安裝成功
    if ! zsh --version &> /dev/null; then
      echo -e "${RED}zsh 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}zsh 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}zsh 已安裝。${NC}"
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

check_awscli() {
  # 檢查是否安裝 awscli
  if ! aws --version &> /dev/null; then
    echo -e "${RED}awscli 未安裝，請先安裝 awscli。${NC}"

  # 安裝 awscli
    echo -e "${YELLOW}開始自動安裝 awscli...${NC}"
    brew install awscli

    # 再次檢查是否安裝成功
    if ! aws --version &> /dev/null; then
      echo -e "${RED}awscli 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}awscli 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}awscli 已安裝。${NC}"
  fi
}

check_granted() {
  # 檢查是否安裝 granted
  if ! granted --version &> /dev/null; then
    echo -e "${RED}granted 未安裝，請先安裝 granted。${NC}"

    # 安裝 granted
    echo -e "${YELLOW}開始自動安裝 granted...${NC}"
    brew tap common-fate/granted
    brew install granted

    # 再次檢查是否安裝成功
    if ! granted -v &> /dev/null; then
      echo -e "${RED}granted 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}granted 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}granted 已安裝。${NC}"
  fi
}

install_session_manager() {
  # 檢查是否已安裝 AWS Session Manager Plugin
  if command -v session-manager-plugin &> /dev/null; then
    echo -e "${GREEN}AWS Session Manager Plugin 已安裝。${NC}"
    return 0
  fi

  echo -e "${YELLOW}開始安裝 AWS Session Manager Plugin...${NC}"
  # 判斷是否為 ARM 架構
  if [ "$(uname -m)" = "arm64" ]; then
      echo "Detected Apple Silicon (ARM64)"
      URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip"
  else
      echo "Detected Intel (x86_64)"
      URL="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip"
  fi

  curl "$URL" -o "sessionmanager-bundle.zip"
  unzip sessionmanager-bundle.zip
  sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

  rm -rf sessionmanager-bundle.zip sessionmanager-bundle
}

uninstall_session_manager() {
  # 卸載 AWS Session Manager Plugin
  sudo rm -rf /usr/local/sessionmanagerplugin
  sudo rm /usr/local/bin/session-manager-plugin
}