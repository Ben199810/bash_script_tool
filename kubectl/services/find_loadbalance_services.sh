#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

switch_context_interface

# 查詢 LoadBalancer 類型的 Service
function find_loadbalancer_services() {
  local QUERY_ALL_NAMESPACES
  local GET_SERVICES

  read -r -p "是否查詢所有命名空間的 Service？(y/n): " QUERY_ALL_NAMESPACES
  if [[ "$QUERY_ALL_NAMESPACES" =~ ^[Yy]$ ]]; then
    GET_SERVICES=$(kubectl get services --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  LoadBalancer IP: \(.spec.loadBalancerIP)"')
  else
    GET_SERVICES=$(kubectl get services -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  LoadBalancer IP: \(.spec.loadBalancerIP)"')
  fi

  echo -e "${BLUE}=== Type 屬於 LoadBalancer 類型的 Service ===${NC}"
  echo -e "${GREEN}${GET_SERVICES}${NC}"
  echo ""
}

find_loadbalancer_services