# 切換至選擇的 Kubernetes Context
function switch_context() {
  # 檢查用戶是否選擇了 Context
  if [ -n "$KUBE_CONTEXT" ]; then
    kubectl config use-context "$KUBE_CONTEXT"
  else
    echo -e "${RED}No context selected. Exiting.${NC}"
    exit 1
  fi
}

# 切換至選擇的 Kubernetes Namespace
function switch_namespace() {
  # 檢查用戶是否選擇了 Namespace
  if [ -n "$KUBE_NAMESPACE" ]; then
    # 去除前綴 "namespace/"
    KUBE_NAMESPACE=${KUBE_NAMESPACE#namespace/}
    kubectl config set-context --current --namespace="$KUBE_NAMESPACE"
  else
    echo -e "${RED}No namespace selected. Exiting.${NC}"
    exit 1
  fi
}

# 使用 fzf 選擇 Kubernetes Context 和 Namespace
KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
switch_context
KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
switch_namespace

# 顯示當前 kubernetes 的 context
CURRENT_CONTEXT=$(kubectl config current-context)
echo -e "${GREEN}Current Kubernetes contexts: $CURRENT_CONTEXT${NC}"

# 顯示當前 kubernetes 的 namespace
CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
echo -e "${GREEN}Current Kubernetes namespace: $CURRENT_NAMESPACE${NC}"