#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

# 此腳本可以在 GCP 專案中搜尋特定的 IP 位址，並顯示相關資源資訊。

SEARCH_MODE=(
  "quick"
  "all"
)

function ask_search_filter() {
  read -p "請輸入要搜尋的 IP 位址: " FILTER
  # 選擇搜尋模式
  echo "請選擇搜尋模式："
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

function search_all_resources() {
  local PROJECT_ID=$1
  local FILTER=$2

  RESULT=$(gcloud asset search-all-resources --scope=projects/${PROJECT_ID} --query="${FILTER}" --quiet 2>/dev/null)
  is_search_complete
}

function search_forwarding_rules() {
  local PROJECT_ID=$1
  local FILTER=$2

  RESULT=$(gcloud compute forwarding-rules list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  is_search_complete
}

function search_addresses() {
  local PROJECT_ID=$1
  local FILTER=$2

  RESULT=$(gcloud compute addresses list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  is_search_complete
}

function search_instances() {
  local PROJECT_ID=$1
  local FILTER=$2

  RESULT=$(gcloud compute instances list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  is_search_complete
}

function is_search_complete() {
  if [ ! -z "${RESULT}" ]; then
    printf "${CLEAR_LINE_AND_HOME}找到了！在 %s\n" "${PROJECT_ID}"
    echo -e "${RESULT}\n"
    url="https://console.cloud.google.com/networking/addresses/list?project=${PROJECT_ID}"
    open "${url}"
    link_name="傳送門"
    echo -e "已開啟瀏覽器, 也可以按住Command再點擊👉\033]8;;${url}\a${link_name}\033]8;;\a\n"
    exit 0
  else
    echo -e "${BLUE}沒有找到結果，表示搜尋未完成${NC}"
    return 1
  fi
}

function main() {
  local PROJECT_ID=$1
  local FILTER=$2

  printf "${CLEAR_LINE_AND_HOME}正在搜尋 %s" "${PROJECT_ID}"

  search_all_resources "${PROJECT_ID}" "${FILTER}"
  search_forwarding_rules "${PROJECT_ID}" "${FILTER}"
  search_addresses "${PROJECT_ID}" "${FILTER}"
  search_instances "${PROJECT_ID}" "${FILTER}"
}

# 將先前定義的函數匯出到環境變數中，使其能夠被子程序存取。
export -f search_all_resources
export -f search_forwarding_rules
export -f search_addresses
export -f search_instances
export -f is_search_complete
export -f main

ask_search_filter

# -j $(nproc) 參數設定工作執行緒數量等於系統 CPU 核心數
parallel --no-notice -j $(nproc) main ::: "${SEARCH_PROJECTS[@]}" ::: "${FILTER}"
echo -e
