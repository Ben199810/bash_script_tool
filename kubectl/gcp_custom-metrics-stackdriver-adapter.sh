#!/bin/bash

# 引入必要的模組
source ../modules/default.sh
source ../modules/kubectl_operate.sh
source ../modules/check_install.sh

# 使用說明
function show_usage() {
    echo -e "${GREEN}=== GCP Custom Metrics Stackdriver Adapter 管理工具 ===${NC}"
    echo ""
    echo -e "${CYAN}使用方式:${NC}"
    echo "  $0 install <yaml_file>   - 安裝/更新 Custom Metrics Stackdriver Adapter"
    echo "  $0 uninstall <yaml_file> - 刪除 Custom Metrics Stackdriver Adapter"
    echo "  $0 status                - 檢查 Custom Metrics Stackdriver Adapter 狀態"
    echo ""
    echo -e "${CYAN}範例:${NC}"
    echo "  $0 install adapter_install.yaml"
    echo "  $0 uninstall adapter_uninstall.yaml"
    echo "  $0 status"
    echo ""
    echo -e "${YELLOW}註: yaml 檔案路徑可以是本地檔案或 URL${NC}"
}

# 檢查參數
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

ACTION="$1"
YAML_FILE="$2"

# 驗證操作模式
case $ACTION in
    install|uninstall)
        if [ -z "$YAML_FILE" ]; then
            echo -e "${RED}錯誤: $ACTION 操作需要指定 yaml 檔案${NC}"
            echo ""
            show_usage
            exit 1
        fi
        
        # 檢查檔案是否存在 (如果是本地檔案)
        if [[ ! "$YAML_FILE" =~ ^https?:// ]] && [ ! -f "$YAML_FILE" ]; then
            echo -e "${RED}錯誤: 找不到檔案 '$YAML_FILE'${NC}"
            exit 1
        fi
        ;;
    status)
        # status 不需要 yaml 檔案
        ;;
    *)
        echo -e "${RED}錯誤: 不支援的操作 '$ACTION'${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

# 檢查 kubectl 是否安裝
check_kubectl

function show_current_context_and_namespace() {
    echo -e "${BLUE}=== 當前 Kubernetes 設定 ===${NC}"
    current_context
    current_namespace
    echo ""
}

function ask_for_context_switch() {
    echo -e "${YELLOW}是否要切換 Kubernetes Context？${NC}"
    echo -e "${CYAN}1. 是，我要切換 Context${NC}"
    echo -e "${CYAN}2. 否，使用當前 Context${NC}"
    echo ""
    read -p "請選擇 (1/2): " choice
    
    case $choice in
        1)
            switch_kubernetes_context
            ;;
        2)
            echo -e "${GREEN}繼續使用當前 Context...${NC}"
            ;;
        *)
            echo -e "${RED}無效選擇，使用當前 Context${NC}"
            ;;
    esac
}

function switch_kubernetes_context() {
    echo -e "${BLUE}可用的 Kubernetes Contexts:${NC}"
    kubectl config get-contexts
    echo ""
    
    # 使用 fzf 選擇 Context
    local KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="選擇一個 Context: " --height 40% --reverse)
    
    if [ -n "$KUBE_CONTEXT" ]; then
        switch_context "$KUBE_CONTEXT"
        echo -e "${GREEN}已切換到 Context: $KUBE_CONTEXT${NC}"
        
        # 詢問是否也要切換 namespace
        ask_for_namespace_switch
    else
        echo -e "${RED}未選擇 Context，保持當前設定${NC}"
    fi
}

function ask_for_namespace_switch() {
    echo ""
    echo -e "${YELLOW}是否要切換 Namespace？${NC}"
    echo -e "${CYAN}1. 是，我要切換 Namespace${NC}"
    echo -e "${CYAN}2. 否，使用當前 Namespace${NC}"
    echo ""
    read -p "請選擇 (1/2): " choice
    
    case $choice in
        1)
            switch_kubernetes_namespace
            ;;
        2)
            echo -e "${GREEN}繼續使用當前 Namespace...${NC}"
            ;;
        *)
            echo -e "${RED}無效選擇，使用當前 Namespace${NC}"
            ;;
    esac
}

function switch_kubernetes_namespace() {
    echo -e "${BLUE}可用的 Namespaces:${NC}"
    kubectl get namespaces -o custom-columns=NAME:.metadata.name --no-headers
    echo ""
    
    # 使用 fzf 選擇 Namespace
    local KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="選擇一個 Namespace: " --height 40% --reverse)
    
    if [ -n "$KUBE_NAMESPACE" ]; then
        switch_namespace "$KUBE_NAMESPACE"
        echo -e "${GREEN}已切換到 Namespace: ${KUBE_NAMESPACE#namespace/}${NC}"
    else
        echo -e "${RED}未選擇 Namespace，保持當前設定${NC}"
    fi
}

function show_final_context_and_namespace() {
    echo ""
    echo -e "${BLUE}=== 最終 Kubernetes 設定 ===${NC}"
    current_context
    current_namespace
}

function check_apiservice_ownership() {
    # 檢查 custom.metrics.k8s.io APIService
    if kubectl get apiservice v1beta1.custom.metrics.k8s.io &>/dev/null; then
        echo -e "${CYAN}檢查 v1beta1.custom.metrics.k8s.io APIService:${NC}"
        local service_info=$(kubectl get apiservice v1beta1.custom.metrics.k8s.io -o jsonpath='{.spec.service.name}/{.spec.service.namespace}')
        echo "  Service: $service_info"
        
        if [[ "$service_info" == "custom-metrics-stackdriver-adapter/custom-metrics" ]]; then
            echo -e "${GREEN}  ✓ 此 APIService 屬於 custom-metrics-stackdriver-adapter${NC}"
        else
            echo -e "${RED}  ⚠ 此 APIService 可能屬於其他服務 (如 Datadog)${NC}"
            echo -e "${YELLOW}  建議不要刪除此 APIService！${NC}"
        fi
    else
        echo -e "${YELLOW}未找到 v1beta1.custom.metrics.k8s.io APIService${NC}"
    fi
    
    # 檢查 external.metrics.k8s.io APIService
    if kubectl get apiservice v1beta1.external.metrics.k8s.io &>/dev/null; then
        echo -e "${CYAN}檢查 v1beta1.external.metrics.k8s.io APIService:${NC}"
        local service_info=$(kubectl get apiservice v1beta1.external.metrics.k8s.io -o jsonpath='{.spec.service.name}/{.spec.service.namespace}')
        echo "  Service: $service_info"
        
        if [[ "$service_info" == "custom-metrics-stackdriver-adapter/custom-metrics" ]]; then
            echo -e "${GREEN}  ✓ 此 APIService 屬於 custom-metrics-stackdriver-adapter${NC}"
        else
            echo -e "${RED}  ⚠ 此 APIService 可能屬於其他服務 (如 Datadog)${NC}"
            echo -e "${YELLOW}  建議不要刪除此 APIService！${NC}"
        fi
    else
        echo -e "${YELLOW}未找到 v1beta1.external.metrics.k8s.io APIService${NC}"
    fi
}

function apply_adapter_config() {
    echo ""
    echo -e "${BLUE}=== 應用 Custom Metrics Stackdriver Adapter 配置 ===${NC}"
    echo -e "${CYAN}使用配置檔案: $YAML_FILE${NC}"
    
    # 使用 kubectl apply --dry-run 檢查變更
    echo -e "${CYAN}正在檢查將要應用的變更 (dry-run)...${NC}"
    echo ""
    
    kubectl apply -f "$YAML_FILE" --dry-run=client
    local dry_run_exit_code=$?
    
    echo ""
    if [ $dry_run_exit_code -eq 0 ]; then
        echo -e "${GREEN}✓ Dry-run 成功 - 上面顯示了將要應用的變更${NC}"
        echo -e "${YELLOW}確認要應用這些變更嗎？ (y/N)${NC}"
    else
        echo -e "${RED}✗ Dry-run 執行時發生錯誤${NC}"
        echo -e "${YELLOW}是否仍要嘗試執行 apply？ (y/N)${NC}"
    fi
    
    read -p "請確認: " confirm
    
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo -e "${CYAN}正在應用配置...${NC}"
        kubectl apply -f "$YAML_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 配置已成功應用${NC}"
            echo ""
            check_adapter_status
        else
            echo -e "${RED}✗ 配置應用失敗${NC}"
        fi
    else
        echo -e "${YELLOW}取消應用操作${NC}"
    fi
}

function delete_adapter_config() {
    echo ""
    echo -e "${BLUE}=== 刪除 Custom Metrics Stackdriver Adapter ===${NC}"
    echo -e "${CYAN}使用配置檔案: $YAML_FILE${NC}"
    
    # 先檢查現有資源
    check_stackdriver_resources
    
    echo ""
    echo -e "${YELLOW}選擇刪除操作模式：${NC}"
    echo -e "${CYAN}1. 預覽將要刪除的資源 (dry-run)${NC}"
    echo -e "${CYAN}2. 刪除指定配置檔案中的所有資源${NC}"
    echo -e "${CYAN}3. 只刪除明確屬於 Stackdriver 的資源（安全模式）${NC}"
    echo -e "${CYAN}4. 取消操作${NC}"
    echo ""
    read -p "請選擇 (1-4): " delete_choice
    
    case $delete_choice in
        1)
            show_delete_preview
            ;;
        2)
            confirm_and_delete_all
            ;;
        3)
            selective_delete
            ;;
        4)
            echo -e "${YELLOW}取消刪除操作${NC}"
            return
            ;;
        *)
            echo -e "${RED}無效選擇，取消操作${NC}"
            return
            ;;
    esac
}

function show_delete_preview() {
    echo ""
    echo -e "${BLUE}=== 預覽將要刪除的資源 (Dry Run) ===${NC}"
    echo -e "${CYAN}檢查配置檔案: $YAML_FILE${NC}"
    echo ""
    
    # 執行 dry-run 刪除
    kubectl delete -f "$YAML_FILE" --dry-run=client
    local dry_run_exit_code=$?
    
    echo ""
    if [ $dry_run_exit_code -eq 0 ]; then
        echo -e "${YELLOW}⚠ 上面顯示的資源將會被刪除${NC}"
        
        # 特別警告 APIService
        echo ""
        echo -e "${RED}特別注意：${NC}"
        echo -e "${YELLOW}如果 APIService (v1beta1.custom.metrics.k8s.io 或 v1beta1.external.metrics.k8s.io) 被其他服務使用，${NC}"
        echo -e "${YELLOW}刪除它們可能會影響其他監控系統（如 Datadog HPA）的正常運作！${NC}"
        
        # 檢查 APIService 歸屬
        echo ""
        echo -e "${CYAN}檢查 APIService 歸屬:${NC}"
        check_apiservice_ownership
        
        echo ""
        echo -e "${YELLOW}確認要繼續執行實際刪除嗎？${NC}"
        echo -e "${CYAN}1. 是，我確認刪除配置檔案中的所有資源${NC}"
        echo -e "${CYAN}2. 否，讓我重新檢查${NC}"
        echo -e "${CYAN}3. 只刪除明確屬於 Stackdriver 的資源${NC}"
        echo ""
        read -p "請選擇 (1-3): " confirm_choice
        
        case $confirm_choice in
            1)
                confirm_and_delete_all
                ;;
            2)
                echo -e "${YELLOW}取消刪除操作${NC}"
                ;;
            3)
                selective_delete
                ;;
            *)
                echo -e "${RED}無效選擇，取消操作${NC}"
                ;;
        esac
    else
        echo -e "${RED}✗ Dry-run 執行失敗，可能配置檔案有問題或沒有相關資源需要刪除${NC}"
    fi
}

function confirm_and_delete_all() {
    echo ""
    echo -e "${RED}警告：這將刪除配置檔案中的所有資源！${NC}"
    echo -e "${RED}包括可能影響其他系統的 APIService！${NC}"
    echo -e "${YELLOW}請輸入 'DELETE-ALL' 來確認刪除所有資源：${NC}"
    read -p "確認: " confirm
    
    if [ "$confirm" = "DELETE-ALL" ]; then
        echo -e "${CYAN}正在刪除配置檔案中的所有資源...${NC}"
        kubectl delete -f "$YAML_FILE"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 配置檔案中的資源已成功刪除${NC}"
            echo ""
            echo -e "${CYAN}驗證刪除結果...${NC}"
            check_adapter_status
        else
            echo -e "${RED}✗ 刪除操作失敗${NC}"
        fi
    else
        echo -e "${YELLOW}取消刪除操作（需要輸入完全匹配的 'DELETE-ALL'）${NC}"
    fi
}

function check_stackdriver_resources() {
    echo ""
    echo -e "${BLUE}=== 檢查 Stackdriver Adapter 相關資源 ===${NC}"
    
    # 檢查是否存在 custom-metrics-stackdriver-adapter 相關資源
    local has_stackdriver_resources=false
    
    # 檢查 Deployment
    if kubectl get deployment custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
        echo -e "${YELLOW}✓ 找到 custom-metrics-stackdriver-adapter Deployment${NC}"
        has_stackdriver_resources=true
    fi
    
    # 檢查 Service
    if kubectl get service custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
        echo -e "${YELLOW}✓ 找到 custom-metrics-stackdriver-adapter Service${NC}"
        has_stackdriver_resources=true
    fi
    
    # 檢查 ServiceAccount
    if kubectl get serviceaccount custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
        echo -e "${YELLOW}✓ 找到 custom-metrics-stackdriver-adapter ServiceAccount${NC}"
        has_stackdriver_resources=true
    fi
    
    # 檢查 RBAC 資源
    if kubectl get clusterrole --no-headers 2>/dev/null | grep -q custom-metrics; then
        echo -e "${YELLOW}✓ 找到 custom-metrics 相關的 ClusterRole${NC}"
        has_stackdriver_resources=true
    fi
    
    if kubectl get clusterrolebinding --no-headers 2>/dev/null | grep -q custom-metrics; then
        echo -e "${YELLOW}✓ 找到 custom-metrics 相關的 ClusterRoleBinding${NC}"
        has_stackdriver_resources=true
    fi
    
    # 檢查 APIService 並確認是否為 Stackdriver Adapter
    echo ""
    echo -e "${CYAN}檢查 APIService 詳細資訊:${NC}"
    check_apiservice_ownership
    
    if [ "$has_stackdriver_resources" = false ]; then
        echo -e "${RED}⚠ 未找到 custom-metrics-stackdriver-adapter 相關資源${NC}"
        echo -e "${YELLOW}可能資源已經被刪除或使用不同的配置${NC}"
        return 1
    fi
    
    return 0
}

function selective_delete() {
    echo ""
    echo -e "${BLUE}=== 選擇性刪除 Stackdriver Adapter 資源 ===${NC}"
    echo -e "${CYAN}只刪除明確屬於 custom-metrics-stackdriver-adapter 的資源...${NC}"
    
    local resources_to_delete=()
    
    # 檢查並準備刪除清單 - 按正確順序排列
    if kubectl get namespace custom-metrics &>/dev/null; then
        # 1. 先刪除 Deployment (停止創建新的 Pod)
        if kubectl get deployment custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
            resources_to_delete+=("deployment/custom-metrics-stackdriver-adapter -n custom-metrics")
        fi
        
        # 2. 刪除 Service
        if kubectl get service custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
            resources_to_delete+=("service/custom-metrics-stackdriver-adapter -n custom-metrics")
        fi
        
        # 3. 刪除 ServiceAccount
        if kubectl get serviceaccount custom-metrics-stackdriver-adapter -n custom-metrics &>/dev/null; then
            resources_to_delete+=("serviceaccount/custom-metrics-stackdriver-adapter -n custom-metrics")
        fi
    fi
    
    # 4. 檢查 ClusterRole 和 ClusterRoleBinding (這些不在 namespace 中)
    local cluster_roles=$(kubectl get clusterrole --no-headers 2>/dev/null | grep custom-metrics | awk '{print $1}')
    for role in $cluster_roles; do
        resources_to_delete+=("clusterrole/$role")
    done
    
    local cluster_role_bindings=$(kubectl get clusterrolebinding --no-headers 2>/dev/null | grep custom-metrics | awk '{print $1}')
    for binding in $cluster_role_bindings; do
        resources_to_delete+=("clusterrolebinding/$binding")
    done
    
    # 5. 檢查 namespace 中的 RoleBinding
    if kubectl get namespace custom-metrics &>/dev/null; then
        local role_bindings=$(kubectl get rolebinding -n custom-metrics --no-headers 2>/dev/null | awk '{print $1}')
        for rb in $role_bindings; do
            resources_to_delete+=("rolebinding/$rb -n custom-metrics")
        done
    fi
    
    if [ ${#resources_to_delete[@]} -eq 0 ]; then
        echo -e "${YELLOW}未找到需要刪除的 Stackdriver Adapter 資源${NC}"
        return
    fi
    
    echo -e "${YELLOW}將要刪除以下資源（按順序）：${NC}"
    for i in "${!resources_to_delete[@]}"; do
        echo "  $((i+1)). ${resources_to_delete[$i]}"
    done
    
    echo ""
    echo -e "${RED}注意：APIService 將被保留以免影響其他服務${NC}"
    echo ""
    echo -e "${YELLOW}確認刪除上述資源嗎？請輸入 'DELETE' 確認：${NC}"
    read -p "確認: " confirm
    
    if [ "$confirm" = "DELETE" ]; then
        echo -e "${CYAN}正在按順序刪除選定的資源...${NC}"
        
        for resource in "${resources_to_delete[@]}"; do
            echo "刪除: $resource"
            kubectl delete $resource --ignore-not-found=true
            sleep 1
        done
        
        echo ""
        echo -e "${GREEN}✓ 選擇性刪除完成${NC}"
        echo ""
        
        # 檢查是否需要刪除 namespace
        if kubectl get namespace custom-metrics &>/dev/null; then
            local remaining_resources=$(kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n custom-metrics 2>/dev/null | grep -v "^NAME" | wc -l)
            
            if [ "$remaining_resources" -eq 0 ]; then
                echo -e "${YELLOW}custom-metrics namespace 現在是空的，是否要刪除它？ (y/N)${NC}"
                read -p "刪除 namespace: " delete_ns
                if [[ $delete_ns == [yY] ]]; then
                    kubectl delete namespace custom-metrics
                    echo -e "${GREEN}✓ 已刪除 custom-metrics namespace${NC}"
                fi
            else
                echo -e "${YELLOW}⚠ namespace 中還有其他資源，保留 namespace${NC}"
            fi
        fi
        
        check_adapter_status
    else
        echo -e "${YELLOW}取消刪除操作${NC}"
    fi
}

function check_adapter_status() {
  echo ""
  echo -e "${BLUE}=== Custom Metrics Stackdriver Adapter 狀態檢查 ===${NC}"

  echo "檢查 Deployment 狀態:"
  kubectl get deployment custom-metrics-stackdriver-adapter -n custom-metrics --no-headers 2>/dev/null || echo "未找到 Deployment"

  echo ""
  echo "檢查 Service 狀態:"
  kubectl get service custom-metrics-stackdriver-adapter -n custom-metrics --no-headers 2>/dev/null || echo "未找到 Service"

  echo ""
  echo "檢查 RBAC 資源 (包含 custom-metrics 關鍵字):"

  echo "ClusterRole:"
  kubectl get clusterrole --no-headers 2>/dev/null | grep custom-metrics || echo "  未找到包含 custom-metrics 的 ClusterRole"

  echo ""
  echo "ClusterRoleBinding:"
  kubectl get clusterrolebinding --no-headers 2>/dev/null | grep custom-metrics || echo "  未找到包含 custom-metrics 的 ClusterRoleBinding"

  echo ""
  echo "ServiceAccount:"
  kubectl get serviceaccount -n custom-metrics --no-headers 2>/dev/null | grep custom-metrics || echo "  未找到包含 custom-metrics 的 ServiceAccount"

  echo ""
  echo "RoleBinding:"
  kubectl get rolebinding -A --no-headers 2>/dev/null | grep custom-metrics || echo "  未找到包含 custom-metrics 的 RoleBinding"

  echo ""
  echo "Role:"
  kubectl get role -A --no-headers 2>/dev/null | grep custom-metrics || echo "  未找到包含 custom-metrics 的 Role"

  echo ""
  echo "檢查 APIService 狀態:"
  kubectl get apiservice | grep custom.metrics.k8s.io || echo "未找到 custom.metrics.k8s.io APIService"
}

function main() {
    echo -e "${GREEN}=== GCP Custom Metrics Stackdriver Adapter 管理工具 ===${NC}"
    echo ""
    
    case $ACTION in
        install)
            echo -e "${CYAN}操作模式: 安裝/更新${NC}"
            echo -e "${CYAN}配置檔案: $YAML_FILE${NC}"
            echo ""
            
            # 顯示當前設定
            show_current_context_and_namespace
            
            # 詢問是否切換
            ask_for_context_switch
            
            # 顯示最終設定
            show_final_context_and_namespace
            
            echo ""
            apply_adapter_config
            ;;
            
        uninstall)
            echo -e "${CYAN}操作模式: 刪除${NC}"
            echo -e "${CYAN}配置檔案: $YAML_FILE${NC}"
            echo ""
            
            # 顯示當前設定
            show_current_context_and_namespace
            
            # 詢問是否切換
            ask_for_context_switch
            
            # 顯示最終設定
            show_final_context_and_namespace
            
            echo ""
            delete_adapter_config
            ;;
            
        status)
            echo -e "${CYAN}操作模式: 狀態檢查${NC}"
            echo ""
            
            # 顯示當前設定
            show_current_context_and_namespace
            
            # 詢問是否切換
            ask_for_context_switch
            
            # 顯示最終設定
            show_final_context_and_namespace
            
            echo ""
            check_adapter_status
            ;;
    esac
}

# 執行主函數
main