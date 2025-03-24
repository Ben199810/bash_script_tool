#!/bin/bash
# 在所有 GCP 專案中搜尋 IP 位址

source ../modules/default.sh

echo -e "${BLUE}輸入你要找的 IP 位址${NC}"
read -p "IP 位址: " FILTER

SELECT_ARRAY=("quick" "all")

PS3="請選擇搜尋範圍: "
select SELECT in "${SELECT_ARRAY[@]}"; do
  case ${SELECT} in
    "quick")
      PROJECTS_ID=(
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
      PROJECTS_ID=($(gcloud projects list --format="value(PROJECT_ID)"))
      break
      ;;
  esac
done

function search_in_project {
  local PROJECT_ID=$1
  local FILTER=$2
  # 遞迴顯示正在搜尋的專案
  # \033[2K 是一個 ANSI 控制碼，用於清除整行內容。
  # \033[0G 是一個 ANSI 控制碼，用於將光標移動到行首。
  printf "\033[2K\033[0G正在搜尋 %s" "${PROJECT_ID}"

  # search-all-resources 搜尋所有資源
  RESULT=$(gcloud asset search-all-resources --scope=projects/${PROJECT_ID} --query="${FILTER}" --quiet 2>/dev/null)

  # 如果沒有找到，則搜尋 forwarding-rules
  if [ -z "${RESULT}" ]; then
    RESULT=$(gcloud compute forwarding-rules list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  fi
  # 如果沒有找到，則搜尋 addresses
  if [ -z "${RESULT}" ]; then
    RESULT=$(gcloud compute addresses list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  fi
  # 如果沒有找到，則搜尋 instances
  if [ -z "${RESULT}" ]; then
    RESULT=$(gcloud compute instances list --filter="${FILTER}" --project "${PROJECT_ID}" --quiet 2>/dev/null)
  fi
  # 如果 RESULT 不為空，則顯示結果
  if [ ! -z "${RESULT}" ]; then
    printf "\033[2K\033[0G找到了！在 %s\n" "${PROJECT_ID}"
    echo -e "${RESULT}\n"
    url="https://console.cloud.google.com/networking/addresses/list?project=${PROJECT_ID}"
    open "${url}"
    link_name="傳送門"
    echo -e "已開啟瀏覽器, 也可以按住Command再點擊👉\033]8;;${url}\a${link_name}\033]8;;\a\n"
  fi
}

export -f search_in_project
parallel --no-notice -j $(nproc) search_in_project ::: "${PROJECTS_ID[@]}" ::: "${FILTER}"
echo -e
