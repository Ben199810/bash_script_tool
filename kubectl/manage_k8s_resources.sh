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

# 額外的顏色定義
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 全域變數存儲搜尋結果
declare -a SEARCH_RESULTS=()
declare -a RESOURCE_TYPES=()
declare -a RESOURCE_NAMES=()
declare -a RESOURCE_NAMESPACES=()

function show_main_menu() {
    echo -e "${BLUE}=== K8s 資源管理工具 ===${NC}"
    echo -e "${CYAN}1. 搜尋資源${NC}"
    echo -e "${CYAN}2. 查看搜尋結果${NC}"
    echo -e "${CYAN}3. 對搜尋結果執行操作${NC}"
    echo -e "${CYAN}4. 清除搜尋結果${NC}"
    echo -e "${CYAN}0. 退出${NC}"
    echo -e "${BLUE}================================${NC}"
    if [ ${#SEARCH_RESULTS[@]} -gt 0 ]; then
        echo -e "${GREEN}目前有 ${#SEARCH_RESULTS[@]} 個搜尋結果${NC}"
    else
        echo -e "${YELLOW}目前沒有搜尋結果${NC}"
    fi
    echo -e "${BLUE}================================${NC}"
}

function search_resources() {
    local resource_type="$1"
    local keyword="$2"
    local namespace="$3"
    
    # 清除之前的搜尋結果
    SEARCH_RESULTS=()
    RESOURCE_TYPES=()
    RESOURCE_NAMES=()
    RESOURCE_NAMESPACES=()
    
    # 使用模組中的搜尋函數
    local search_output
    search_output=$(search_k8s_resources "$resource_type" "$keyword" "$namespace")
    
    if [[ -n "$search_output" ]]; then
        echo -e "${GREEN}找到以下資源:${NC}"
        local line_number=1
        
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*$ ]]; then
                echo -e "${CYAN}[$line_number]${NC} $line"
                
                # 解析資源資訊
                local name
                local ns
                
                if [[ -z "$namespace" ]]; then
                    # 全 namespace 搜尋格式: NAMESPACE NAME READY STATUS ...
                    ns=$(echo "$line" | awk '{print $1}')
                    name=$(echo "$line" | awk '{print $2}')
                else
                    # 單 namespace 搜尋格式: NAME READY STATUS ...
                    name=$(echo "$line" | awk '{print $1}')
                    ns="$namespace"
                fi
                
                # 確保名稱和命名空間不為空且不是標題行
                if [[ -n "$name" && -n "$ns" && "$name" != "NAME" && "$ns" != "NAMESPACE" ]]; then
                    SEARCH_RESULTS+=("$line")
                    RESOURCE_TYPES+=("$resource_type")
                    RESOURCE_NAMES+=("$name")
                    RESOURCE_NAMESPACES+=("$ns")
                    ((line_number++))
                fi
            fi
        done <<< "$search_output"
        
        echo -e "\n${GREEN}共找到 ${#SEARCH_RESULTS[@]} 個資源${NC}"
    else
        echo -e "${YELLOW}沒有找到相關的 $resource_type${NC}"
    fi
}

function show_search_results() {
    if [ ${#SEARCH_RESULTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}目前沒有搜尋結果${NC}"
        return
    fi
    
    echo -e "${BLUE}=== 搜尋結果 ===${NC}"
    
    for i in "${!SEARCH_RESULTS[@]}"; do
        local index=$((i + 1))
        echo -e "${CYAN}[$index]${NC} ${RESOURCE_TYPES[$i]}: ${SEARCH_RESULTS[$i]}"
    done
    echo -e "${BLUE}================================${NC}"
    echo -e "${GREEN}共 ${#SEARCH_RESULTS[@]} 個資源${NC}"
}

function show_action_menu() {
    echo -e "${BLUE}=== 資源操作選擇 ===${NC}"
    echo -e "${RED}1. 刪除選定的資源${NC}"
    echo -e "${CYAN}2. 查看資源詳細資訊${NC}"
    echo -e "${CYAN}3. 查看資源 YAML${NC}"
    echo -e "${CYAN}0. 返回主選單${NC}"
    echo -e "${BLUE}================================${NC}"
}

function select_resources_for_action() {
    if [ ${#SEARCH_RESULTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}沒有搜尋結果可供操作${NC}" >&2
        return 1
    fi
    
    # 將搜尋結果輸出到 stderr，避免被函數返回值捕獲
    show_search_results >&2
    echo "" >&2
    echo -e "${YELLOW}請選擇要操作的資源 (輸入編號，多個編號用空格分隔，輸入 'all' 選擇全部):${NC}" >&2
    read -p "選擇: " selection
    
    local selected_indices=()
    
    if [[ "$selection" == "all" ]]; then
        for i in $(seq 0 $((${#SEARCH_RESULTS[@]} - 1))); do
            selected_indices+=($i)
        done
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#SEARCH_RESULTS[@]} ]; then
                selected_indices+=($((num - 1)))
            else
                echo -e "${RED}無效的選擇: $num${NC}" >&2
            fi
        done
    fi
    
    if [ ${#selected_indices[@]} -eq 0 ]; then
        echo -e "${RED}沒有有效的選擇${NC}" >&2
        return 1
    fi
    
    echo "${selected_indices[@]}"
    return 0
}

function handle_search() {
    while true; do
        # 使用模組中的搜尋選單函數
        show_k8s_search_menu
        read -p "請選擇搜尋類型 (0-10): " search_choice
        
        # 使用模組中的函數將選擇轉換為資源類型
        local resource_type
        resource_type=$(get_resource_type_from_choice "$search_choice")
        
        if [[ "$search_choice" == "0" ]]; then
            return
        elif [[ -z "$resource_type" ]]; then
            echo -e "${RED}無效的選擇${NC}"
            continue
        fi
        
        read -p "請輸入搜尋關鍵字: " keyword
        read -p "請輸入 namespace (留空表示所有 namespace): " namespace
        
        search_resources "$resource_type" "$keyword" "$namespace"
        break
    done
}

function handle_actions() {
    if [ ${#SEARCH_RESULTS[@]} -eq 0 ]; then
        echo -e "${YELLOW}請先執行搜尋以獲得結果${NC}"
        return
    fi
    
    while true; do
        show_action_menu
        read -p "請選擇操作 (0-3): " action_choice
        
        case $action_choice in
            1) delete_resources ;;
            2) describe_resources ;;
            3) show_resource_yaml ;;
            0) return ;;
            *)
                echo -e "${RED}無效的選擇${NC}"
                continue
                ;;
        esac
        break
    done
}

function delete_resources() {
    local indices_output
    indices_output=$(select_resources_for_action)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        return
    fi
    
    read -a selected_indices <<< "$indices_output"
    
    echo -e "\n${RED}將要刪除以下資源:${NC}"
    for index in "${selected_indices[@]}"; do
        echo -e "${RED}  - ${RESOURCE_TYPES[$index]}: ${RESOURCE_NAMES[$index]} (namespace: ${RESOURCE_NAMESPACES[$index]})${NC}"
    done
    
    echo -e "\n${YELLOW}確定要刪除這些資源嗎? 此操作無法復原!${NC}"
    read -p "請輸入 'DELETE' 確認刪除: " confirmation
    
    if [[ "$confirmation" != "DELETE" ]]; then
        echo -e "${GREEN}操作已取消${NC}"
        return
    fi
    
    echo -e "\n${YELLOW}開始刪除資源...${NC}"
    local success_count=0
    local fail_count=0
    
    for index in "${selected_indices[@]}"; do
        local resource_type="${RESOURCE_TYPES[$index]}"
        local resource_name="${RESOURCE_NAMES[$index]}"
        local resource_namespace="${RESOURCE_NAMESPACES[$index]}"
        
        echo -e "${CYAN}刪除 $resource_type/$resource_name (namespace: $resource_namespace)...${NC}"
        
        if kubectl delete "$resource_type" "$resource_name" -n "$resource_namespace" 2>/dev/null; then
            echo -e "${GREEN}  ✓ 刪除成功${NC}"
            ((success_count++))
        else
            echo -e "${RED}  ✗ 刪除失敗${NC}"
            ((fail_count++))
        fi
    done
    
    echo -e "\n${BLUE}=== 刪除結果 ===${NC}"
    echo -e "${GREEN}成功: $success_count${NC}"
    echo -e "${RED}失敗: $fail_count${NC}"
    
    # 清除搜尋結果
    SEARCH_RESULTS=()
    RESOURCE_TYPES=()
    RESOURCE_NAMES=()
    RESOURCE_NAMESPACES=()
    echo -e "${YELLOW}搜尋結果已清除${NC}"
}

function describe_resources() {
    local indices_output
    indices_output=$(select_resources_for_action)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        return
    fi
    
    read -a selected_indices <<< "$indices_output"
    
    for index in "${selected_indices[@]}"; do
        local resource_type="${RESOURCE_TYPES[$index]}"
        local resource_name="${RESOURCE_NAMES[$index]}"
        local resource_namespace="${RESOURCE_NAMESPACES[$index]}"
        
        echo -e "\n${BLUE}=== $resource_type/$resource_name (namespace: $resource_namespace) ===${NC}"
        kubectl describe "$resource_type" "$resource_name" -n "$resource_namespace"
        echo -e "\n${CYAN}按 Enter 繼續查看下一個資源...${NC}"
        read
    done
}

function show_resource_yaml() {
    local indices_output
    indices_output=$(select_resources_for_action)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        return
    fi
    
    read -a selected_indices <<< "$indices_output"
    
    for index in "${selected_indices[@]}"; do
        local resource_type="${RESOURCE_TYPES[$index]}"
        local resource_name="${RESOURCE_NAMES[$index]}"
        local resource_namespace="${RESOURCE_NAMESPACES[$index]}"
        
        echo -e "\n${BLUE}=== $resource_type/$resource_name (namespace: $resource_namespace) YAML ===${NC}"
        kubectl get "$resource_type" "$resource_name" -n "$resource_namespace" -o yaml
        echo -e "\n${CYAN}按 Enter 繼續查看下一個資源...${NC}"
        read
    done
}

# 主程式
# 檢查依賴工具 (使用模組中的函數)
check_k8s_dependencies

while true; do
    show_main_menu
    read -p "請選擇操作 (0-4): " choice
    
    case $choice in
        1) handle_search ;;
        2) show_search_results ;;
        3) handle_actions ;;
        4) 
            SEARCH_RESULTS=()
            RESOURCE_TYPES=()
            RESOURCE_NAMES=()
            RESOURCE_NAMESPACES=()
            echo -e "${GREEN}搜尋結果已清除${NC}"
            ;;
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