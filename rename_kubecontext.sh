#!/bin/bash

source ./colors.sh
source ./check_install.sh

check_kubectl

CURRENT_CONTEXTS=$(kubectl config get-contexts -o=name)

# 使用 fzf 選擇 context
SELECTED_CONTEXT=$(echo "$CURRENT_CONTEXTS" | fzf --prompt="Select a kube context: ")

# 重新命名 context
echo -n "Enter new name for the selected context: "
read NEW_CONTEXT_NAME

# 檢查 NEW_CONTEXT_NAME 是否有輸入或是空值
if [ -z "$NEW_CONTEXT_NAME" ]; then
    echo "Error: New context name cannot be empty."
    exit 1
fi

kubectl config rename-context "$SELECTED_CONTEXT" "$NEW_CONTEXT_NAME"
