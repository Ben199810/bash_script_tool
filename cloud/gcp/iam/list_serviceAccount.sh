#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

# 查看所有服務帳戶的 IAM 角色

function list_serviceAccount() {
    echo -e "${BLUE}Listing Service Accounts in project: $CURRENT_PROJECT_ID${NC}"

    local SERVICEACCOUNTS=$(gcloud iam service-accounts list \
        --project="$CURRENT_PROJECT_ID" \
        --format="value(email)")

    if [ -z "$SERVICEACCOUNTS" ]; then
        echo -e "${YELLOW}No service accounts found in project: $CURRENT_PROJECT_ID${NC}"
    else
        echo "$SERVICEACCOUNTS"
    fi
}

main () {
    ask_switch_gcp_project_interface
    list_serviceAccount
}

main