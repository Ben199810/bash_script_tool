#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

# 查詢 LoadBalancer 類型的 Service
function find_loadbalancer_services() {
  local SERVICES

  SERVICES=$(kubectl get services $NAMESPACE_OPTION $KUBE_CONTEXT_OPTION -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  LoadBalancer IP: \(.spec.loadBalancerIP)"')

  echo -e "${BLUE}=== Type 屬於 LoadBalancer 類型的 Service ===${NC}"
  echo -e "${GREEN}${SERVICES}${NC}"
  echo ""
}