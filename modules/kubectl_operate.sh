function current_context() {
  CURRENT_CONTEXT=$(kubectl config current-context)
  echo -e "${BLUE}Current Kubernetes contexts: $CURRENT_CONTEXT${NC}"
}

function current_namespace() {
  CURRENT_NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
  echo -e "${BLUE}Current Kubernetes namespace: $CURRENT_NAMESPACE${NC}"
}

function switch_context() {
  KUBE_CONTEXT=$1
  if [ -n "$KUBE_CONTEXT" ]; then
    kubectl config use-context "$KUBE_CONTEXT"
  else
    echo -e "${RED}No context selected. Exiting.${NC}"
    exit 1
  fi
}

function switch_namespace() {
  KUBE_NAMESPACE=$1
  if [ -n "$KUBE_NAMESPACE" ]; then
    # 去除前綴 "namespace/"
    KUBE_NAMESPACE=${KUBE_NAMESPACE#namespace/}
    kubectl config set-context --current --namespace="$KUBE_NAMESPACE"
  else
    echo -e "${RED}No namespace selected. Exiting.${NC}"
    exit 1
  fi
}

function assign_context_and_namespace() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  if [[ -n "$ASSIGNATION_CONTEXT" ]]; then
    CURRENT_CONTEXT=$ASSIGNATION_CONTEXT
  fi
  if [[ -n "$ASSIGNATION_NAMESPACE" ]]; then
    CURRENT_NAMESPACE=$ASSIGNATION_NAMESPACE
  fi
}

function get_deployment() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Listing deployments in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get deployment --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp'
}

function get_ingress() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Listing ingress in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get ingress --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,HOSTS:.spec.rules[*].host,ADDRESS:.status.loadBalancer.ingress[*].ip'
}

function get_namespace() {
  local CURRENT_CONTEXT="$1"

  echo -e "${BLUE}Listing namespaces in context: $CURRENT_CONTEXT${NC}"
  kubectl get namespace --context="$CURRENT_CONTEXT" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.phase'
}

function get_pdb() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Listing pod disruption budgets in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get pdb --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp'
}

get_pod() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  assign_context_and_namespace "$ASSIGNATION_CONTEXT" "$ASSIGNATION_NAMESPACE"

  echo -e "${BLUE}Listing pods in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get pod --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp'
}

get_service() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  assign_context_and_namespace "$ASSIGNATION_CONTEXT" "$ASSIGNATION_NAMESPACE"

  echo -e "${BLUE}Listing services in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl get service --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,EXTERNAL-IP:.status.loadBalancer.ingress[*].ip'
}

function get_all_pdb() {
  local CURRENT_CONTEXT="$1"

  echo -e "${BLUE}Listing all pod disruption budgets in context: $CURRENT_CONTEXT${NC}"
  kubectl get pdb --context="$CURRENT_CONTEXT" -A -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp'
}

function describe_pdb() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"
  # fzf
  local PDB_NAME=$(kubectl get pdb --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name' | fzf --height 40% --reverse --inline-info --header="Select a Pod Disruption Budget to describe")

  echo -e "${BLUE}Describing Pod Disruption Budget: $PDB_NAME in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl describe pdb "$PDB_NAME" --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE"
}

function describe_backendConfig() {
  local ASSIGNATION_CONTEXT="$1"
  local ASSIGNATION_NAMESPACE="$2"

  assign_context_and_namespace "$ASSIGNATION_CONTEXT" "$ASSIGNATION_NAMESPACE"
  # fzf
  local BACKEND_CONFIG_NAME=$(kubectl get backendconfig --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name' | fzf --height 40% --reverse --inline-info --header="Select a BackendConfig to describe")

  echo -e "${BLUE}Describing BackendConfig: $BACKEND_CONFIG_NAME in context: $CURRENT_CONTEXT, namespace: $CURRENT_NAMESPACE${NC}"
  kubectl describe backendconfig "$BACKEND_CONFIG_NAME" --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE"
}

function delete_namespace() {
  local CURRENT_CONTEXT="$1"
  local CURRENT_NAMESPACE="$2"

  echo -e "${BLUE}Deleting namespace: $CURRENT_NAMESPACE in context: $CURRENT_CONTEXT${NC}"
  kubectl delete namespace "$CURRENT_NAMESPACE" --context="$CURRENT_CONTEXT"
}