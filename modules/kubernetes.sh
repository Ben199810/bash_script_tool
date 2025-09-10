#!/bin/bash

# Kubernetes 相關函數模組

# 詢問是否查詢所有命名空間
function ask_query_all_namespaces() {
    read -r -p "是否查詢所有命名空間？(y/n): " QUERY_ALL_NAMESPACES
    # 標準化輸入：將輸入轉換為小寫並檢查是否為 y 或 yes
    case "${QUERY_ALL_NAMESPACES}" in
        y|yes)
            QUERY_ALL_NAMESPACES="true"
            echo -e "${GREEN}✅ 將查詢所有命名空間${NC}"
            echo ""
            return 0
            ;;
        *)
            QUERY_ALL_NAMESPACES="false"
            echo -e "${YELLOW}⚠️ 將不查詢所有命名空間${NC}"
            echo ""
            return 1
            ;;
    esac
}

# 檢查是否查詢所有命名空間（布林值版本）
function is_query_all_namespaces() {
    [[ "$QUERY_ALL_NAMESPACES" == "true" ]]
}

# 獲取命名空間參數
function get_namespace_option() {
    if is_query_all_namespaces; then
        echo "--all-namespaces"
    else
        echo ""
    fi
}

function get_context_option() {
    if [ -n "$KUBE_CONTEXT" ]; then
        echo "--context=$KUBE_CONTEXT"
    else
        echo ""
    fi
}

# 選擇 Kubernetes 資源類型
function select_kubernetes_resources() {
    local RESOURCE_TYPE_ARRAY=(
      pod
      pdb
      service
    )
    RESOURCE_TYPE=$(printf "%s\n" "${RESOURCE_ARRAY[@]}" | fzf --prompt="選擇 Kubernetes 資源類型: ")
}

# 獲取選定的 Kubernetes 資源
function get_selected_kubernetes_resource() {
    echo -e "${BLUE}搜尋 Kubernetes 資源: ${RESOURCE_TYPE}${NC}"
    local NAMESPACE_OPTION=$(get_namespace_option)
    local KUBE_CONTEXT_OPTION=$(get_context_option)
    RESOURCE_ARRAY=$(kubectl get "${RESOURCE_TYPE}" ${NAMESPACE_OPTION} ${KUBE_CONTEXT_OPTION} --no-headers 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ 無法取得 ${RESOURCE_TYPE} 列表，請檢查 kubectl 連線${NC}"
        return 1
    fi

    if [[ -z "$RESOURCE_ARRAY" ]]; then
        echo -e "${YELLOW}⚠️ 叢集中沒有找到任何 ${RESOURCE_TYPE}${NC}"
        return 0
    fi
}

# 常用的 kubernetes context 清單
function get_all_contexts() {
  local CONTEXTS_OUTPUT
  CONTEXTS_OUTPUT=$(kubectl config get-contexts -o name 2>/dev/null)
  if [ -z "$CONTEXTS_OUTPUT" ]; then
    echo -e "${RED}沒有找到任何 Kubernetes contexts${NC}" >&2
    return 1
  fi
  
  # 將字串轉換為陣列（使用更相容的方法）
  KUBERNETES_CONTEXTS=()
  while IFS= read -r LINE; do
    [ -n "$LINE" ] && KUBERNETES_CONTEXTS+=("$LINE")
  done <<< "$CONTEXTS_OUTPUT"
}

function get_common_contexts() {
  KUBERNETES_CONTEXTS=(
    gke_gcp-20220425-004_asia-east1-b_bbin-interface-dev
    gke_gcp-20220425-005_asia-east1-b_bbin-interface-qa
    gke_gcp-20220425-006_asia-east1_bbin-interface-prod
    gke_gcp-20220425-010_asia-east1-b_platform-dev
    gke_gcp-20220425-011_asia-east1-b_platform-test
    gke_gcp-20220425-012_asia-east1_bbin-platform-prod
    gke_gcp-20220425-013_asia-east1-b_bbin-outside-dev
    gke_gcp-20220425-014_asia-east1-b_bbin-outside-qa
    gke_gcp-20220425-015_asia-east1_bbin-outside-prod-multiregion
    gke_gcp-20221202-001_asia-southeast1-c_rd1-bbchat-prod
    gke_gcp-20221202-002_asia-southeast1-c_rd1-bbchat-qa
    gke_gcp-20221202-003_asia-southeast1-c_rd1-bbchat-dev
    gke_gcp-20231102-003_asia-east1_bbin-pa-prod
    gke_gcp-20240131-024_asia-east1_bbin-interface-staging
    gke_gcp-20240131-025_asia-east1_bbin-platform-staging
    gke_gcp-20240131-026_asia-east1_bbin-outside-staging
    gke_gcp-20240131-028_asia-east1_bbin-pa-staging
    gke_gcp-20240205-003_asia-east1-b_bbgp-platform-staging
    gke_gcp-20240205-004_asia-east1-b_outside-staging
    gke_gcp-20240426-001_asia-southeast1-c_rd1-bbchat-staging
    gke_gcp-20250421-001_asia-east1-b_bbgp-interface-dev
    gke_gcp-20250421-007_asia-east1-b_bbgp-outside-dev
    gke_midori-pd-it_asia-southeast1_midori-it
    gke_midori-pd-staging_asia-southeast1_midori-staging
    gke_ph-btg-pd_asia-southeast1_midori-prod
    gke_rd6-project_asia-east1-b_bb-prod-game-platform
    gke_rd6-project_asia-east1-b_bb-qa-game-platform
    gke_rd6-project_asia-east1-b_outside-prod
    gke_rd6-project_asia-east1-b_outside-qa
  )
}