#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

switch_context_interface

function list_ingresses() {
  local QUERY_ALL_NAMESPACES
  local GET_INGRESSES

  ask_query_all_namespaces
  local NAMESPACE_OPTION=$(get_namespace_option)

  GET_INGRESSES=$(kubectl get ingresses $NAMESPACE_OPTION -o json | jq -r '.items[] | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  所屬類別: \(.spec.ingressClassName // "N/A")  LoadBalancer IP: \(.status.loadBalancer.ingress[0].ip // "N/A") \n"')

  echo -e "${BLUE}=== Ingress 列表 ===${NC}"
  echo -e "${GREEN}${GET_INGRESSES}${NC}"
  echo ""
}

list_ingresses