#!/bin/bash
# 取得執行腳本當前目錄
DIR="$(dirname $0)"
source ${DIR}/../default.sh

function main() {
  check_and_install_brew
  check_and_install_iterm2
}

main