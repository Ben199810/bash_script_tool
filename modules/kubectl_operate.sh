function assign_context_and_namespace() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  if [[ -n "$ASSIGNATION_CONTEXT" ]]; then
    CURRENT_CONTEXT=$ASSIGNATION_CONTEXT
  fi
  if [[ -n "$ASSIGNATION_NAMESPACE" ]]; then
    CURRENT_NAMESPACE=$ASSIGNATION_NAMESPACE
  fi
}

function get_deployment() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Listing deployments in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get deployment --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp'
}

function get_ingress() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Listing ingress in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get ingress --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[*].ip'
}

function get_namespace() {
  local CURRENT_CONTEXT="$1"

  echo -e "${BLUE}Listing namespaces in context: $CURRENT_CONTEXT${NC}"
  kubectl get namespace --context="$CURRENT_CONTEXT" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.phase'
}

function describe_backendConfig() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  assign_context_and_namespace "$ASSIGNATION_CONTEXT" "$ASSIGNATION_NAMESPACE"
  # fzf
  local BACKEND_CONFIG_NAME=$(kubectl get backendconfig --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name' | fzf --height 40% --reverse --inline-info --header="Select a BackendConfig to describe")

  echo -e "${BLUE}Describing BackendConfig: $BACKEND_CONFIG_NAME in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl describe backendconfig "$BACKEND_CONFIG_NAME" --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE"
}

function delete_namespace() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Deleting namespace: $CURRENT_NAMESPACE in context: $CURRENT_CONTEXT${NC}"
  kubectl delete namespace "$CURRENT_NAMESPACE" --context="$CURRENT_CONTEXT"
}

# 檢查必要工具
function check_k8s_dependencies() {
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

# 通用的搜尋資源函數
function search_k8s_resources() {
    local resource_type="$1"
    local keyword="$2"
    local namespace="$3"
    
    # 將搜尋說明文字輸出到 stderr，避免干擾搜尋結果
    echo -e "${YELLOW}搜尋 $resource_type 中包含 '$keyword' 的資源...${NC}" >&2
    
    # 設定 namespace 參數
    local ns_param=""
    if [[ -z "$namespace" ]]; then
        ns_param="--all-namespaces"
    else
        ns_param="-n $namespace"
    fi
    
    # 執行搜尋並返回結果
    kubectl get "$resource_type" $ns_param --no-headers 2>/dev/null | grep -i "$keyword"
}

# 通用的顯示搜尋選單函數
function show_k8s_search_menu() {
    echo -e "${BLUE}=== 搜尋類型選擇 ===${NC}"
    echo -e "${CYAN}1. 搜尋 Pod${NC}"
    echo -e "${CYAN}2. 搜尋 Service${NC}"
    echo -e "${CYAN}3. 搜尋 Deployment${NC}"
    echo -e "${CYAN}4. 搜尋 StatefulSet${NC}"
    echo -e "${CYAN}5. 搜尋 ConfigMap${NC}"
    echo -e "${CYAN}6. 搜尋 Secret${NC}"
    echo -e "${CYAN}7. 搜尋 Ingress${NC}"
    echo -e "${CYAN}8. 搜尋 PVC${NC}"
    echo -e "${CYAN}9. 搜尋 Job${NC}"
    echo -e "${CYAN}10. 搜尋 CronJob${NC}"
    echo -e "${CYAN}0. 返回主選單${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 將搜尋選項轉換為資源類型
function get_resource_type_from_choice() {
    local choice="$1"
    case $choice in
        1) echo "pods" ;;
        2) echo "services" ;;
        3) echo "deployments" ;;
        4) echo "statefulsets" ;;
        5) echo "configmaps" ;;
        6) echo "secrets" ;;
        7) echo "ingress" ;;
        8) echo "pvc" ;;
        9) echo "jobs" ;;
        10) echo "cronjobs" ;;
        *) echo "" ;;
    esac
}

# 智慧搜尋功能（包含多種資源類型的搜尋）
function smart_k8s_search() {
    local keyword="$1"
    local namespace="$2"
    
    echo -e "${GREEN}=== 智慧搜尋結果：關鍵字 '$keyword' ===${NC}"
    
    # 設定 namespace 參數
    local ns_param=""
    if [[ -z "$namespace" ]]; then
        ns_param="--all-namespaces"
    else
        ns_param="-n $namespace"
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
    
    echo -e "\n${CYAN}🔍 搜尋 Roles:${NC}"
    kubectl get roles $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 Role"
    
    echo -e "\n${CYAN}🔍 搜尋 ClusterRoles:${NC}"
    kubectl get clusterroles 2>/dev/null | grep -i "$keyword" || echo "  無相關 ClusterRole"
    
    echo -e "\n${CYAN}🔍 搜尋 RoleBindings:${NC}"
    kubectl get rolebindings $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 RoleBinding"
    
    echo -e "\n${CYAN}🔍 搜尋 ClusterRoleBindings:${NC}"
    kubectl get clusterrolebindings 2>/dev/null | grep -i "$keyword" || echo "  無相關 ClusterRoleBinding"
    
    echo -e "\n${CYAN}🔍 搜尋 ServiceAccounts:${NC}"
    kubectl get serviceaccounts $ns_param 2>/dev/null | grep -i "$keyword" || echo "  無相關 ServiceAccount"
    
    # 只在搜尋所有 namespace 時搜尋 Node 和 Namespace
    if [[ -z "$namespace" ]]; then
        echo -e "\n${CYAN}🔍 搜尋 Nodes:${NC}"
        kubectl get nodes 2>/dev/null | grep -i "$keyword" || echo "  無相關 Node"
        
        echo -e "\n${CYAN}🔍 搜尋 Namespaces:${NC}"
        kubectl get namespaces 2>/dev/null | grep -i "$keyword" || echo "  無相關 Namespace"
    fi
    
    # 高級 RBAC 搜尋：根據關鍵字搜尋權限關聯
    echo -e "\n${CYAN}🔐 RBAC 權限關聯搜尋:${NC}"
    
    # 搜尋 RoleBindings 中引用包含關鍵字的 Role
    local role_binding_results
    role_binding_results=$(kubectl get rolebindings $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.roleRef.name | test($keyword; "i")) |
        "RoleBinding: \(.metadata.name) (namespace: \(.metadata.namespace // "default")) -> Role: \(.roleRef.name)"
    ' 2>/dev/null)
    
    if [[ -n "$role_binding_results" ]]; then
        echo "  引用相關 Role 的 RoleBinding:"
        echo "$role_binding_results"
    fi
    
    # 搜尋 ClusterRoleBindings 中引用包含關鍵字的 ClusterRole
    local cluster_role_binding_results
    cluster_role_binding_results=$(kubectl get clusterrolebindings -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.roleRef.name | test($keyword; "i")) |
        "ClusterRoleBinding: \(.metadata.name) -> ClusterRole: \(.roleRef.name)"
    ' 2>/dev/null)
    
    if [[ -n "$cluster_role_binding_results" ]]; then
        echo "  引用相關 ClusterRole 的 ClusterRoleBinding:"
        echo "$cluster_role_binding_results"
    fi
    
    # 搜尋 RoleBindings 中引用 ClusterRole 的情況
    local rolebinding_clusterrole_results
    rolebinding_clusterrole_results=$(kubectl get rolebindings $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.roleRef.kind == "ClusterRole" and (.roleRef.name | test($keyword; "i"))) |
        "RoleBinding: \(.metadata.name) (namespace: \(.metadata.namespace)) -> ClusterRole: \(.roleRef.name)"
    ' 2>/dev/null)
    
    if [[ -n "$rolebinding_clusterrole_results" ]]; then
        echo "  RoleBindings 引用相關 ClusterRole:"
        echo "$rolebinding_clusterrole_results"
    fi
    
    # 搜尋包含關鍵字的 ServiceAccount 相關的權限綁定
    local sa_binding_results
    sa_binding_results=$(kubectl get rolebindings,clusterrolebindings $ns_param -o json 2>/dev/null | jq -r --arg keyword "$keyword" '
        .items[] | 
        select(.subjects[]? | select(.kind == "ServiceAccount" and (.name | test($keyword; "i")))) |
        "\(.kind): \(.metadata.name) -> ServiceAccount: \(.subjects[] | select(.kind == "ServiceAccount" and (.name | test($keyword; "i"))) | .name)"
    ' 2>/dev/null)
    
    if [[ -n "$sa_binding_results" ]]; then
        echo "  ServiceAccount 相關的權限綁定:"
        echo "$sa_binding_results"
    fi
    
    if [[ -z "$role_binding_results" && -z "$cluster_role_binding_results" && -z "$rolebinding_clusterrole_results" && -z "$sa_binding_results" ]]; then
        echo "  無相關 RBAC 權限關聯"
    fi
    
    echo -e "\n${GREEN}=== 搜尋完成 ===${NC}"
}