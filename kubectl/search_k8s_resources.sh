#!/bin/bash

# 取得腳本目錄
SCRIPT_DIR="$(dirname $0)"

# 引入預設設定（包含顏色定義）
if [[ -f "$SCRIPT_DIR/../modules/default.sh" ]]; then
    source "$SCRIPT_DIR/../modules/default.sh"
else
    echo "警告: 找不到 modules/default.sh，使用預設顏色設定"
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
fi

# 引入 kubectl 操作模組
if [[ -f "$SCRIPT_DIR/../modules/kubectl_operate.sh" ]]; then
    source "$SCRIPT_DIR/../modules/kubectl_operate.sh"
else
    echo "警告: 找不到 modules/kubectl_operate.sh，部分功能可能無法使用"
fi

# 引入 kubectl context 切換功能（可選）
if [[ -f "$SCRIPT_DIR/switch_kubernetes_context.sh" ]]; then
    source "$SCRIPT_DIR/switch_kubernetes_context.sh"
else
    echo "警告: 找不到 switch_kubernetes_context.sh，跳過 context 切換功能"
fi

# 額外的顏色定義（modules/default.sh 中沒有的）
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function show_menu() {
    echo -e "${BLUE}=== K8s 資源搜尋工具 ===${NC}"
    echo -e "${CYAN}1. 搜尋 Pod${NC}"
    echo -e "${CYAN}2. 搜尋 Service${NC}"
    echo -e "${CYAN}3. 搜尋 Deployment${NC}"
    echo -e "${CYAN}4. 搜尋 StatefulSet${NC}"
    echo -e "${CYAN}5. 搜尋 ConfigMap${NC}"
    echo -e "${CYAN}6. 搜尋 Secret${NC}"
    echo -e "${CYAN}7. 搜尋 Ingress${NC}"
    echo -e "${CYAN}8. 搜尋 PVC (PersistentVolumeClaim)${NC}"
    echo -e "${CYAN}9. 搜尋 Node${NC}"
    echo -e "${CYAN}10. 搜尋 Namespace${NC}"
    echo -e "${CYAN}11. 搜尋 Role${NC}"
    echo -e "${CYAN}12. 搜尋 ClusterRole${NC}"
    echo -e "${CYAN}13. 全域搜尋 (所有資源)${NC}"
    echo -e "${CYAN}14. 按標籤搜尋${NC}"
    echo -e "${CYAN}15. 按映像檔搜尋${NC}"
    echo -e "${GREEN}16. 智慧關鍵字搜尋 (推薦)${NC}"
    echo -e "${CYAN}0. 退出${NC}"
    echo -e "${BLUE}================================${NC}"
}

function search_pods() {
    read -p "請輸入要搜尋的 Pod 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "pods" "$keyword" "$namespace"
}

function search_services() {
    read -p "請輸入要搜尋的 Service 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "services" "$keyword" "$namespace"
}

function search_deployments() {
    read -p "請輸入要搜尋的 Deployment 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "deployments" "$keyword" "$namespace"
}

function search_statefulsets() {
    read -p "請輸入要搜尋的 StatefulSet 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "statefulsets" "$keyword" "$namespace"
}

function search_configmaps() {
    read -p "請輸入要搜尋的 ConfigMap 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "configmaps" "$keyword" "$namespace"
}

function search_secrets() {
    read -p "請輸入要搜尋的 Secret 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "secrets" "$keyword" "$namespace"
}

function search_ingress() {
    read -p "請輸入要搜尋的 Ingress 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "ingress" "$keyword" "$namespace"
}

function search_pvc() {
    read -p "請輸入要搜尋的 PVC 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "pvc" "$keyword" "$namespace"
}

function search_nodes() {
    read -p "請輸入要搜尋的 Node 名稱關鍵字: " keyword
    
    echo -e "${YELLOW}搜尋包含 '$keyword' 的 Node...${NC}"
    kubectl get nodes | grep -i "$keyword"
}

function search_namespaces() {
    read -p "請輸入要搜尋的 Namespace 名稱關鍵字: " keyword
    
    echo -e "${YELLOW}搜尋包含 '$keyword' 的 Namespace...${NC}"
    kubectl get namespaces | grep -i "$keyword"
}

function search_roles() {
    read -p "請輸入要搜尋的 Role 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    search_k8s_resources "roles" "$keyword" "$namespace"
}

function search_cluster_roles() {
    read -p "請輸入要搜尋的 ClusterRole 名稱關鍵字: " keyword
    
    echo -e "${YELLOW}搜尋包含 '$keyword' 的 ClusterRole...${NC}"
    kubectl get clusterroles | grep -i "$keyword"
}

function search_all_resources() {
    read -p "請輸入要搜尋的關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}在所有 namespace 中搜尋包含 '$keyword' 的所有資源...${NC}"
        kubectl get all --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}在 namespace '$namespace' 中搜尋包含 '$keyword' 的所有資源...${NC}"
        kubectl get all -n "$namespace" | grep -i "$keyword"
    fi
}

function search_by_label() {
    read -p "請輸入標籤選擇器 (例如: app=nginx): " label_selector
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋標籤為 '$label_selector' 的所有資源...${NC}"
        kubectl get all --all-namespaces -l "$label_selector"
    else
        echo -e "${YELLOW}在 namespace '$namespace' 中搜尋標籤為 '$label_selector' 的資源...${NC}"
        kubectl get all -n "$namespace" -l "$label_selector"
    fi
}

function search_by_image() {
    read -p "請輸入要搜尋的映像檔關鍵字: " image_keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    echo -e "${YELLOW}搜尋使用映像檔包含 '$image_keyword' 的 Pod...${NC}"
    
    if [[ -z "$namespace" ]]; then
        kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" | tr ' ' '\n' | grep -i "$image_keyword" | sort -u
        echo -e "\n${CYAN}相關的 Pod:${NC}"
        kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.spec.containers[].image | test("'$image_keyword'"; "i")) | "\(.metadata.namespace)/\(.metadata.name)"'
    else
        kubectl get pods -n "$namespace" -o jsonpath="{.items[*].spec.containers[*].image}" | tr ' ' '\n' | grep -i "$image_keyword" | sort -u
        echo -e "\n${CYAN}相關的 Pod:${NC}"
        kubectl get pods -n "$namespace" -o json | jq -r '.items[] | select(.spec.containers[].image | test("'$image_keyword'"; "i")) | "\(.metadata.name)"'
    fi
}

function smart_keyword_search() {
    read -p "請輸入搜尋關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    # 使用模組中的智慧搜尋功能
    smart_k8s_search "$keyword" "$namespace"
}

# 主程式
# 檢查依賴工具 (使用模組中的函數)
check_k8s_dependencies

while true; do
    show_menu
    read -p "請選擇操作 (0-16): " choice
    
    case $choice in
        1) search_pods ;;
        2) search_services ;;
        3) search_deployments ;;
        4) search_statefulsets ;;
        5) search_configmaps ;;
        6) search_secrets ;;
        7) search_ingress ;;
        8) search_pvc ;;
        9) search_nodes ;;
        10) search_namespaces ;;
        11) search_roles ;;
        12) search_cluster_roles ;;
        13) search_all_resources ;;
        14) search_by_label ;;
        15) search_by_image ;;
        16) smart_keyword_search ;;
        0) 
            echo -e "${GREEN}退出程式${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}無效的選擇，請重新輸入${NC}"
            ;;
    esac
    
    echo ""
    read -p "按 Enter 鍵繼續..."
    echo ""
done