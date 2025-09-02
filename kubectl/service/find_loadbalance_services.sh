#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

switch_context_interface

# 查詢 LoadBalancer 類型的 Service
function find_loadbalancer_services() {
  local QUERY_ALL_NAMESPACES
  local GET_SERVICES

  ask_query_all_namespaces
  local NAMESPACE_OPTION=$(get_namespace_option)

  GET_SERVICES=$(kubectl get services $NAMESPACE_OPTION -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  LoadBalancer IP: \(.spec.loadBalancerIP)"')

  echo -e "${BLUE}=== Type 屬於 LoadBalancer 類型的 Service ===${NC}"
  echo -e "${GREEN}${GET_SERVICES}${NC}"
  echo ""
}

find_loadbalancer_services