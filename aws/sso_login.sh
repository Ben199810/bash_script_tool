#!/bin/bash

# 取得執行腳本當前目錄
DIR="$(dirname $0)"

# 字體顏色
source ../${DIR}/modules/colors.sh

accounts_list=($(aws configure list-profiles))

PS3="Select AWS Account: "
select selected_account in "${accounts_list[@]}"; do
    case $selected_account in
      *)
        if [[ -n "$selected_account" ]]; then
          echo -e "${BLUE}Selected AWS Account: $selected_account${NC}"
          aws sso login --profile $selected_account
          echo -e "${GREEN}SSO Success login: $selected_account${NC}"
        else
          echo -e "${RED}Invalid selection.${NC}"
        fi
        break
        ;;
    esac
done