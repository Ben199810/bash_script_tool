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

# 選擇 Kubernetes 資源類型
function select_kubernetes_resources() {
    local RESOURCE_TYPE_ARRAY=(
      pod
      pdb
    )
    RESOURCE_TYPE=$(printf "%s\n" "${RESOURCE_ARRAY[@]}" | fzf --prompt="選擇 Kubernetes 資源類型: ")
}

# 獲取選定的 Kubernetes 資源
function get_selected_kubernetes_resource() {
    echo -e "${BLUE}搜尋 Kubernetes 資源: ${RESOURCE_TYPE}${NC}"
    local NAMESPACE_OPTION=$(get_namespace_option)
    RESOURCE_ARRAY=$(kubectl get "${RESOURCE_TYPE}" ${NAMESPACE_OPTION} --no-headers 2>/dev/null)

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}❌ 無法取得 ${RESOURCE_TYPE} 列表，請檢查 kubectl 連線${NC}"
        return 1
    fi

    if [[ -z "$RESOURCE_ARRAY" ]]; then
        echo -e "${YELLOW}⚠️ 叢集中沒有找到任何 ${RESOURCE_TYPE}${NC}"
        return 0
    fi
}