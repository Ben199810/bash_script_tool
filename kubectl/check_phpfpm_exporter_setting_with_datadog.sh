#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh.sh

# 列出 deployments 內的所有 container
# 如果有 container 名稱是 php-exporter，則顯示該 container 的資訊、deployment 的 annotations

DEPLOYMENTS=$(kubectl get deployment --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
if [ -z "$DEPLOYMENTS" ]; then
  echo -e "${RED}No deployments found.${NC}"
  exit 1
fi

for DEPLOYMENT in $DEPLOYMENTS; do
  CONTAINER_NAME=$(kubectl get deployment $DEPLOYMENT --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].name}')
  if [[ "$CONTAINER_NAME" == *"phpfpm-exporter"* ]]; then
    echo -e "${BLUE}Selected deployment: $DEPLOYMENT${NC}"
    echo -e "${GREEN}Container Name: $CONTAINER_NAME${NC}"
    echo -e "${YELLOW}Annotations: $(kubectl get deployment $DEPLOYMENT --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.metadata.annotations}')${NC}"
  fi
done