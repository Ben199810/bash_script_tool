#!/bin/bash
source ../../modules/default.sh

CURRENT_CONTEXTS=$(kubectl config get-contexts -o=name)

# 使用 fzf 選擇 context
SELECTED_CONTEXT=$(echo "$CURRENT_CONTEXTS" | fzf --prompt="Select a kube context: ")

# 重新命名 context
echo -n -e "${BLUE}Enter new name for the selected context: ${NC}"
read NEW_CONTEXT_NAME

# 檢查 NEW_CONTEXT_NAME 是否有輸入或是空值
if [ -z "$NEW_CONTEXT_NAME" ]; then
    echo -e "${RED}Error: New context name cannot be empty.${NC}"
    exit 1
fi

kubectl config rename-context "$SELECTED_CONTEXT" "$NEW_CONTEXT_NAME"
