#!/bin/bash

# 取得執行腳本當前目錄
DIR="$(dirname $0)"

source ../${DIR}/modules/default.sh
source ../${DIR}/modules/check_install.sh

check_brew
check_iterm2
check_zsh
check_kubectl
check_helm
check_awscli
check_granted