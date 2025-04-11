# 顯示當前 kubernetes 的 context
function current_context() {
  CURRENT_CONTEXT=$(kubectl config current-context)
  echo -e "${BLUE}Current Kubernetes contexts: $CURRENT_CONTEXT${NC}"
}

# 顯示當前 kubernetes 的 namespace
function current_namespace() {
  CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
  echo -e "${BLUE}Current Kubernetes namespace: $CURRENT_NAMESPACE${NC}"
}

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

# 顯示當前 kubernetes 的 context & namespace
current_context
current_namespace

# 是否要切換 Kubernetes Context
read -p "Do you want to switch Kubernetes Context? (y/n): " SWITCH_CONTEXT
if [[ "$SWITCH_CONTEXT" =~ ^[Yy]$ ]]; then
  # 使用 fzf 選擇 Kubernetes Context
  KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")
  switch_context
  # 使用 fzf 選擇 Kubernetes Namespace
  KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")
  switch_namespace
else
  echo -e "${YELLOW}Skipping context switch.${NC}"
fi

# 顯示當前 kubernetes 的 context & namespace
current_context
current_namespace