#!/bin/bash
set -euo pipefail

DIR=$(dirname "$0")
source "$DIR/default.sh"

# 此腳本可以在 GCP 專案中搜尋特定的 IP 位址，並顯示相關資源資訊。

SEARCH_MODE=(
  "quick"
  "all"
)

function validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

function ask_search_filter() {
    while true; do
        read -p "請輸入要搜尋的 IP 位址: " FILTER
        if [[ -n "$FILTER" ]] && validate_ip "$FILTER"; then
            break
        else
            echo "錯誤：請輸入有效的 IP 位址格式 (例如: 192.168.1.1)"
        fi
    done
    # 選擇搜尋模式
    PS3="請選擇搜尋模式："
    select MODE in "${SEARCH_MODE[@]}"; do
        case $MODE in
            "quick")
                echo "已選擇快速搜尋模式"
                SEARCH_PROJECTS=(
                  rd-gateway          # rd-gateway
                  gcp-202011216-001   # rd-gateway2
                  rd6-project         # pid-project(bbgp)
                  gcp-20210526-001    # pid common
                  gcp-20220425-012    # bbin-platform-prod
                  gcp-20220425-011    # bbin-platform-qa
                  gcp-20220425-010    # bbin-platform-dev
                  gcp-20220425-015    # bbin-outside-prod
                  gcp-20220425-014    # bbin-outside-qa
                  gcp-20220425-013    # bbin-outside-dev
                  gcp-20220425-006    # bbin-interface-prod
                  gcp-20220425-005    # bbin-interface-qa
                  gcp-20220425-004    # bbin-interface-dev
                  gcp-20221202-003    # bb-chat-dev
                  gcp-20221202-002    # bb-chat-qa
                  gcp-20221202-001    # bb-chat-prod
                  gcp-20231102-003    # bbin-pa-prod
                  gcp-20231102-002    # bbin-pa-qa
                  gcp-20231102-001    # bbin-pa-dev
                )
                break
                ;;
            "all")
                echo "已選擇全面搜尋模式"
                SEARCH_PROJECTS=($(gcloud projects list --format="value(PROJECT_ID)"))
                break
                ;;
            *)
                echo "無效的選擇，請重新選擇"
                ;;
        esac
    done
}

function is_result_empty() {
    [[ -z "${RESULT}" ]]
}

function is_search_complete() {
  if [[ -n "${RESULT}" ]]; then
    printf "\033[2K\033[0G找到了！在 %s\n" "${PROJECT_ID}"
    echo -e "${RESULT}\n"

    url="https://console.cloud.google.com/networking/addresses/list?project=${PROJECT_ID}"
    if command -v open &> /dev/null; then
        open "${url}"
    fi
    link_name="傳送門"
    echo -e "已開啟瀏覽器, 也可以按住Command再點擊👉\033]8;;${url}\a${link_name}\033]8;;\a\n"
    return 0
  fi
  return 1
}

function search_all_resources() {
  local PROJECT_ID=$1
  local FILTER=$2

  if is_result_empty; then
    RESULT=$(gcloud asset search-all-resources --scope=projects/${PROJECT_ID} --query="${FILTER}" --quiet 2>/dev/null)
    is_search_complete
  fi
}

function search_forwarding_rules() {
  local PROJECT_ID=$1
  local FILTER=$2 

  if is_result_empty; then
    RESULT=$(gcloud compute forwarding-rules list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
    is_search_complete
  fi
}

function search_addresses() {
  local PROJECT_ID=$1
  local FILTER=$2

  if is_result_empty; then
    RESULT=$(gcloud compute addresses list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
    is_search_complete
  fi
}

function search_instances() {
  local PROJECT_ID=$1
  local FILTER=$2

  if is_result_empty; then
    RESULT=$(gcloud compute instances list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
    is_search_complete
  fi
}

function main() {
  local PROJECT_ID=$1
  local FILTER=$2

  # \033[2K 是一個 ANSI 控制碼，用於清除整行內容。
  # \033[0G 是一個 ANSI 控制碼，用於將光標移動到行首。

  printf "\033[2K\033[0G正在搜尋 %s" "${PROJECT_ID}"

  search_all_resources "${PROJECT_ID}" "${FILTER}"
  search_forwarding_rules "${PROJECT_ID}" "${FILTER}"
  search_addresses "${PROJECT_ID}" "${FILTER}"
  search_instances "${PROJECT_ID}" "${FILTER}"
}

# 將先前定義的函數匯出到環境變數中，使其能夠被子程序存取。
export -f is_result_empty
export -f is_search_complete
export -f search_all_resources
export -f search_forwarding_rules
export -f search_addresses
export -f search_instances
export -f main

ask_search_filter

# -j $(nproc) 參數設定工作執行緒數量等於系統 CPU 核心數
parallel --no-notice -j $(nproc) main ::: "${SEARCH_PROJECTS[@]}" ::: "${FILTER}"
