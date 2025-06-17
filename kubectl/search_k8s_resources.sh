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

# 引入 kubectl context 切換功能（可選）
if [[ -f "$SCRIPT_DIR/switch_kubernetes_context.sh" ]]; then
    source "$SCRIPT_DIR/switch_kubernetes_context.sh"
else
    echo "警告: 找不到 switch_kubernetes_context.sh，跳過 context 切換功能"
fi

# 額外的顏色定義（modules/default.sh 中沒有的）
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 檢查必要工具
function check_dependencies() {
    local missing_tools=()
    
    # 檢查 kubectl
    if ! command -v kubectl &> /dev/null; then
        missing_tools+=("kubectl")
    fi
    
    # 檢查 jq（智慧搜尋功能需要）
    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}錯誤: 缺少必要工具: ${missing_tools[*]}${NC}"
        echo -e "${YELLOW}請安裝缺少的工具後再執行此腳本${NC}"
        echo ""
        echo "安裝指令:"
        for tool in "${missing_tools[@]}"; do
            case $tool in
                kubectl)
                    echo "  brew install kubectl"
                    ;;
                jq)
                    echo "  brew install jq"
                    ;;
            esac
        done
        exit 1
    fi
}

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
    echo -e "${CYAN}11. 全域搜尋 (所有資源)${NC}"
    echo -e "${CYAN}12. 按標籤搜尋${NC}"
    echo -e "${CYAN}13. 按映像檔搜尋${NC}"
    echo -e "${GREEN}14. 智慧關鍵字搜尋 (推薦)${NC}"
    echo -e "${CYAN}0. 退出${NC}"
    echo -e "${BLUE}================================${NC}"
}

function search_pods() {
    read -p "請輸入要搜尋的 Pod 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 Pod...${NC}"
        kubectl get pods --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 Pod...${NC}"
        kubectl get pods -n "$namespace" | grep -i "$keyword"
    fi
}

function search_services() {
    read -p "請輸入要搜尋的 Service 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 Service...${NC}"
        kubectl get services --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 Service...${NC}"
        kubectl get services -n "$namespace" | grep -i "$keyword"
    fi
}

function search_deployments() {
    read -p "請輸入要搜尋的 Deployment 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 Deployment...${NC}"
        kubectl get deployments --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 Deployment...${NC}"
        kubectl get deployments -n "$namespace" | grep -i "$keyword"
    fi
}

function search_statefulsets() {
    read -p "請輸入要搜尋的 StatefulSet 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 StatefulSet...${NC}"
        kubectl get statefulsets --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 StatefulSet...${NC}"
        kubectl get statefulsets -n "$namespace" | grep -i "$keyword"
    fi
}

function search_configmaps() {
    read -p "請輸入要搜尋的 ConfigMap 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 ConfigMap...${NC}"
        kubectl get configmaps --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 ConfigMap...${NC}"
        kubectl get configmaps -n "$namespace" | grep -i "$keyword"
    fi
}

function search_secrets() {
    read -p "請輸入要搜尋的 Secret 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 Secret...${NC}"
        kubectl get secrets --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 Secret...${NC}"
        kubectl get secrets -n "$namespace" | grep -i "$keyword"
    fi
}

function search_ingress() {
    read -p "請輸入要搜尋的 Ingress 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 Ingress...${NC}"
        kubectl get ingress --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 Ingress...${NC}"
        kubectl get ingress -n "$namespace" | grep -i "$keyword"
    fi
}

function search_pvc() {
    read -p "請輸入要搜尋的 PVC 名稱關鍵字: " keyword
    read -p "請輸入 namespace (留空表示所有 namespace): " namespace
    
    if [[ -z "$namespace" ]]; then
        echo -e "${YELLOW}搜尋所有 namespace 中包含 '$keyword' 的 PVC...${NC}"
        kubectl get pvc --all-namespaces | grep -i "$keyword"
    else
        echo -e "${YELLOW}搜尋 namespace '$namespace' 中包含 '$keyword' 的 PVC...${NC}"
        kubectl get pvc -n "$namespace" | grep -i "$keyword"
    fi
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
    
    echo -e "${GREEN}=== 智慧搜尋結果：關鍵字 '$keyword' ===${NC}"
    
    # 設定 namespace 參數
    if [[ -z "$namespace" ]]; then
        ns_param="--all-namespaces"
        ns_flag=""
    else
        ns_param="-n $namespace"
        ns_flag="-n $namespace"
    fi
    
    # 搜尋各種資源類型
    echo -e "\n${CYAN}🔍 搜尋 Pods:${NC}"
    kubectl get pods $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Pod"
    
    echo -e "\n${CYAN}🔍 搜尋 Services:${NC}"
    kubectl get services $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Service"
    
    echo -e "\n${CYAN}🔍 搜尋 Deployments:${NC}"
    kubectl get deployments $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Deployment"
    
    echo -e "\n${CYAN}🔍 搜尋 StatefulSets:${NC}"
    kubectl get statefulsets $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 StatefulSet"
    
    echo -e "\n${CYAN}🔍 搜尋 ConfigMaps:${NC}"
    kubectl get configmaps $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 ConfigMap"
    
    echo -e "\n${CYAN}🔍 搜尋 Secrets:${NC}"
    kubectl get secrets $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Secret"
    
    echo -e "\n${CYAN}🔍 搜尋 Ingress:${NC}"
    kubectl get ingress $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Ingress"
    
    echo -e "\n${CYAN}🔍 搜尋 PVCs:${NC}"
    kubectl get pvc $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 PVC"
    
    # 只在搜尋所有 namespace 時搜尋 Node 和 Namespace
    if [[ -z "$namespace" ]]; then
        echo -e "\n${CYAN}🔍 搜尋 Nodes:${NC}"
        kubectl get nodes 2>/dev/null | grep -i "$keyword" || echo "  無相關 Node"
        
        echo -e "\n${CYAN}🔍 搜尋 Namespaces:${NC}"
        kubectl get namespaces 2>/dev/null | grep -i "$keyword" || echo "  無相關 Namespace"
    fi
    
    # 搜尋標籤包含關鍵字的資源
    echo -e "\n${CYAN}🏷️  搜尋標籤包含 '$keyword' 的資源:${NC}"
    local label_results
    label_results=$(kubectl get all $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.metadata.labels // {} | to_entries[] | .key or .value | test($keyword; "i")) |
        "\(.kind)/\(.metadata.name) (namespace: \(.metadata.namespace // "default"))"
    ' 2>/dev/null | head -10)
    
    if [[ -n "$label_results" ]]; then
        echo "$label_results"
    else
        echo "  無相關標籤資源"
    fi
    
    # 搜尋映像檔包含關鍵字的 Pod
    echo -e "\n${CYAN}🐳 搜尋映像檔包含 '$keyword' 的 Pod:${NC}"
    local image_results
    image_results=$(kubectl get pods $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.spec.containers[]?.image // "" | test($keyword; "i")) |
        "\(.metadata.namespace // "default")/\(.metadata.name) - 映像檔: \(.spec.containers[].image)"
    ' 2>/dev/null | head -10)
    
    if [[ -n "$image_results" ]]; then
        echo "$image_results"
    else
        echo "  無使用相關映像檔的 Pod"
    fi
    
    # 搜尋資源描述或註解包含關鍵字
    echo -e "\n${CYAN}📝 搜尋註解包含 '$keyword' 的資源:${NC}"
    local annotation_results
    annotation_results=$(kubectl get all $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.metadata.annotations // {} | to_entries[] | .key or .value | test($keyword; "i")) |
        "\(.kind)/\(.metadata.name) (namespace: \(.metadata.namespace // "default"))"
    ' 2>/dev/null | head -5)
    
    if [[ -n "$annotation_results" ]]; then
        echo "$annotation_results"
    else
        echo "  無相關註解資源"
    fi
    
    echo -e "\n${GREEN}=== 搜尋完成 ===${NC}"
}

# 主程式
# 檢查依賴工具
check_dependencies

while true; do
    show_menu
    read -p "請選擇操作 (0-14): " choice
    
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
        11) search_all_resources ;;
        12) search_by_label ;;
        13) search_by_image ;;
        14) smart_keyword_search ;;
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