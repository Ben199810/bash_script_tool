#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

switch_context_interface

function list_ingresses() {
  local QUERY_ALL_NAMESPACES
  local GET_INGRESSES

  read -r -p "是否查詢所有命名空間的 Ingress？(y/n): " QUERY_ALL_NAMESPACES
  if [[ "$QUERY_ALL_NAMESPACES" =~ ^[Yy]$ ]]; then
    GET_INGRESSES=$(kubectl get ingresses --all-namespaces -o json | jq -r '.items[] | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  所屬類別: \(.spec.ingressClassName // "N/A")  LoadBalancer IP: \(.status.loadBalancer.ingress[0].ip // "N/A") \n"')
  else
    GET_INGRESSES=$(kubectl get ingresses -o json | jq -r '.items[] | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  所屬類別: \(.spec.ingressClassName // "N/A")  LoadBalancer IP: \(.status.loadBalancer.ingress[0].ip // "N/A") \n"')
  fi

  echo -e "${BLUE}=== Ingress 列表 ===${NC}"
  echo -e "${GREEN}${GET_INGRESSES}${NC}"
  echo ""
}

list_ingresses