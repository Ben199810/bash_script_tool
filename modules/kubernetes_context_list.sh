KUBE_CONTEXT=$(kubectl config get-contexts -o name | fzf --prompt="Select a context: ")

# 切換至選擇的 Kubernetes Context
function switch_context() {
  # 檢查用戶是否選擇了 Context
  if [ -n "$KUBE_CONTEXT" ]; then
    echo -e "${BLUE}Switching to context: $KUBE_CONTEXT${NC}"
    kubectl config use-context "$KUBE_CONTEXT"
    echo -e "${GREEN}Switched to context: $(kubectl config current-context)${NC}"
  else
    echo -e "${RED}No context selected. Exiting.${NC}"
    exit 1
  fi
}

KUBE_NAMESPACE=$(kubectl get namespaces -o name | fzf --prompt="Select a namespace: ")

# 切換至選擇的 Kubernetes Namespace
function switch_namespace() {
  # 檢查用戶是否選擇了 Namespace
  if [ -n "$KUBE_NAMESPACE" ]; then
    echo -e "${BLUE}Switching to namespace: $KUBE_NAMESPACE${NC}"
    kubectl config set-context --current --namespace="$KUBE_NAMESPACE"
    echo -e "${GREEN}Switched to namespace: $(kubectl config view --minify -o jsonpath='{..namespace}')${NC}"
  else
    echo -e "${RED}No namespace selected. Exiting.${NC}"
    exit 1
  fi
}