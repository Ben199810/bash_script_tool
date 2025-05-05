#!/bin/bash

source ../modules/default.sh

aws_get_profiles() {
    aws configure list-profiles
}

aws_choose_profile() {
    profiles=($(aws_get_profiles))

    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "${RED}未找到 AWS 配置文件，请先配置 AWS CLI${WHITE}"
        exit 1
    fi
    profile=$(printf "%s\n" "${profiles[@]}" | fzf --prompt="👆 請選擇 AWS 帳號：")
    if [ -z "$profile" ]; then
        echo -e "${RED}未選擇 AWS 帳號，退出腳本 ....${WHITE}"
        exit 1
    fi

    aws_confirm_profile
}

aws_confirm_profile() {
    echo -e "\n${BLUE}======= 選擇為 ${YELLOW}${profile}${WHITE} ${BLUE}=======${WHITE}\n"
    echo -e "手動執行指令如下：\n${GREEN}aws sso login --profile ${profile}\n${WHITE}"
    read -r -e -p "是否要執行 SSO 登入？ (請輸入 apply)：" continue
    case $continue in
    "apply")
        aws_sso_login ${profile}
        ;;
    esac
}

aws_sso_login() {
    aws sso login --profile ${profile}
}

aws_choose_profile