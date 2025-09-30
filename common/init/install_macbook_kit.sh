#!/bin/bash
DIR="$(dirname $0)"
source ${DIR}/../../modules/default.sh
source ${DIR}/../../modules/check_install.sh

NPM_KIT_ARRAY=(
  "@github/copilot"
)

function main() {
  check_and_install_brew
  check_and_install_iterm2
  check_and_install_zsh
  check_and_install_ohmyzsh
  check_kubectl
  check_helm
  check_awscli
  check_and_install_gitkraken
  check_and_install_docker
}

main