function get_deployment() {
  local current_context="$1"
  local current_namespace="$2"

  echo -e "${BLUE}Listing deployments in context: $current_context, namespace: $current_namespace${NC}"
  kubectl get deployment --context="$current_context" -n "$current_namespace" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp'
}

function get_ingress() {
  local current_context="$1"
  local current_namespace="$2"

  echo -e "${BLUE}Listing ingress in context: $current_context, namespace: $current_namespace${NC}"
  kubectl get ingress --context="$current_context" -n "$current_namespace" -o 'custom-columns=NAME:.metadata.name,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[*].ip'
}

function get_namespace() {
  local current_context="$1"

  echo -e "${BLUE}Listing namespaces in context: $current_context${NC}"
  kubectl get namespace --context="$current_context" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.phase'
}

function delete_namespace() {
  local current_context="$1"
  local current_namespace="$2"

  echo -e "${BLUE}Deleting namespace: $current_namespace in context: $current_context${NC}"
  kubectl delete namespace "$current_namespace" --context="$current_context"
}