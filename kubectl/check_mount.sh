#!/bin/bash
source ./switch_kubernetes_context.sh

pod_df() {
  SEARCH_KEYWORD="$1"
  CONTAINER_NAME="$2"

  PODS=$(kubectl get pod --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name' | grep $SEARCH_KEYWORD)
  if [ -z "$PODS" ]; then
    echo "No pods found with keyword: $SEARCH_KEYWORD"
    exit 0
  fi

  for POD in $PODS; do
    echo -e "${BLUE}Checking pod: $POD${NC}"
    kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h
  done
}


pod_df "eagle-website-system-0" "go"
pod_df "wolf-activity-0" "go"
pod_df "ipl-ctl-background-0" "php"
pod_df "aio-api-ball-member-58fbd7d484-b4wkk" "php"
pod_df "aio-web-ball-member-66c8bdd74d-dkwwd" "php"
pod_df "ball-member-1-dfb56fd5f-7h8xs" "php"