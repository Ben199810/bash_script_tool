function check_and_install_brew() {
  if ! brew -v &> /dev/null; then
    echo -e "${RED}brew 未安裝，請先安裝 brew。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 brew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if ! brew -v &> /dev/null; then
      echo -e "${RED}brew 安裝失敗，請手動安裝。${NC}"
      echo -e "${YELLOW}請參考官網指引：https://brew.sh${NC}"
      exit 1
    else
      echo -e "${GREEN}brew 安裝成功。${NC}"
      echo ""
    fi
  else
    echo -e "${GREEN}brew 已安裝。${NC}"
    echo ""
  fi
}
function check_and_install_iterm2() {
  if ! open -a iTerm &> /dev/null; then
    echo -e "${RED}iTerm2 未安裝，請先安裝 iTerm2。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 iTerm2...${NC}"
    brew install --cask iterm2

    # 安裝後再次檢查
    if [ -d "/Applications/iTerm.app" ] || mdfind "kMDItemCFBundleIdentifier == 'com.googlecode.iterm2'" | grep -q "iTerm.app"; then
      echo -e "${GREEN}iTerm2 安裝成功。${NC}"
      echo ""
    else
      echo -e "${RED}iTerm2 安裝失敗，請手動安裝。${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}iTerm2 已安裝。${NC}"
    echo ""
  fi
}

function check_and_install_zsh() {
  if ! zsh --version &> /dev/null; then
    echo -e "${RED}zsh 未安裝，請先安裝 zsh。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 zsh...${NC}"
    brew install zsh

    if ! zsh --version &> /dev/null; then
      echo -e "${RED}zsh 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}zsh 安裝成功。${NC}"
      echo ""
    fi
  else
    echo -e "${GREEN}zsh 已安裝。${NC}"
    echo ""
  fi
}

function check_and_install_ohmyzsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${RED}oh-my-zsh 未安裝，請先安裝 oh-my-zsh。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
      echo -e "${RED}oh-my-zsh 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}oh-my-zsh 安裝成功。${NC}"
      echo ""
    fi
  else
    echo -e "${GREEN}oh-my-zsh 已安裝。${NC}"
    echo ""
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
    if ! kubectl version --client &> /dev/null; then
      echo -e "${RED}kubectl 安裝失敗，請手動安裝。${NC}"
      exit 1
    else
      echo -e "${GREEN}kubectl 安裝成功。${NC}"
    fi
  else
    echo -e "${GREEN}kubectl 已安裝。${NC}"
    echo ""
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
    echo ""
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
    echo ""
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
    echo ""
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

function check_and_install_gitkraken() {
  # 使用多種方法檢查 GitKraken 是否已安裝
  if [ -d "/Applications/GitKraken.app" ] || mdfind "kMDItemCFBundleIdentifier == 'com.axosoft.gitkraken'" | grep -q "GitKraken.app"; then
    echo -e "${GREEN}GitKraken 已安裝。${NC}"
    echo ""
    return 0
  fi
  
  if ! open -a "GitKraken" &> /dev/null; then
    echo -e "${RED}GitKraken 未安裝，請先安裝 GitKraken。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 GitKraken...${NC}"
    brew install --cask gitkraken
    sleep 5

    # 安裝後再次檢查
    if [ -d "/Applications/GitKraken.app" ] || mdfind "kMDItemCFBundleIdentifier == 'com.axosoft.gitkraken'" | grep -q "GitKraken.app"; then
      echo -e "${GREEN}GitKraken 安裝成功。${NC}"
      echo ""
    else
      echo -e "${RED}GitKraken 安裝失敗，請手動安裝。${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}GitKraken 已安裝。${NC}"
    echo ""
  fi
}

# 安裝 docker desktop GUI 介面
function check_and_install_docker() {
  if [ -d "/Applications/Docker.app" ] || mdfind "kMDItemCFBundleIdentifier == 'com.docker.docker'" | grep -q "Docker.app"; then
    echo -e "${GREEN}Docker Desktop 已安裝。${NC}"
    echo ""
    return 0
  fi

  if ! open -a Docker &> /dev/null; then
    echo -e "${RED}Docker Desktop 未安裝，請先安裝 Docker Desktop。${NC}"
    echo ""

    echo -e "${YELLOW}開始自動安裝 Docker Desktop...${NC}"
    brew install --cask docker-desktop
    sleep 5

    # 安裝後再次檢查
    if [ -d "/Applications/Docker.app" ] || mdfind "kMDItemCFBundleIdentifier == 'com.docker.docker'" | grep -q "Docker.app"; then
      echo -e "${GREEN}Docker Desktop 安裝成功。${NC}"
      echo ""
    else
      echo -e "${RED}Docker Desktop 安裝失敗，請手動安裝。${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}Docker Desktop 已安裝。${NC}"
    echo ""
  fi
}

