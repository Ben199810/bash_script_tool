#!/bin/bash

# Kubernetes 相關函數模組

# 詢問是否查詢所有命名空間
ask_query_all_namespaces() {
    read -r -p "是否查詢所有命名空間？(y/n): " QUERY_ALL_NAMESPACES
    
    # 標準化輸入：將輸入轉換為小寫並檢查是否為 y 或 yes
    case "${QUERY_ALL_NAMESPACES}" in
        y|yes)
            QUERY_ALL_NAMESPACES="true"
            return 0
            ;;
        *)
            QUERY_ALL_NAMESPACES="false"
            return 1
            ;;
    esac
}

# 檢查是否查詢所有命名空間（布林值版本）
is_query_all_namespaces() {
    [[ "$QUERY_ALL_NAMESPACES" == "true" ]]
}

# 獲取命名空間參數
get_namespace_option() {
    if is_query_all_namespaces; then
        echo "--all-namespaces"
    else
        echo ""
    fi
}