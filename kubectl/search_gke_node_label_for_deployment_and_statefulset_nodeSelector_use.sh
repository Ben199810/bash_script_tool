#!/bin/bash
source ./switch_kubernetes_context.sh

GKE_NODE_LABELS=(
  aio-ub-member
  ball-member-1
  ball-member-2
  ball-member-3
  ball-member-4
  ball-member-anti-hack
  ctl-web-api
  hall-ag
  hall-callduck
)
USE_GKE_NODE_LABEL_DEPLOYMENTS=()
USE_GKE_NODE_LABEL_STATEFULSETS=()
DEPLOYMENTS=$(kubectl get deployments -o jsonpath='{.items[*].metadata.name}')
STATEFULESETS=$(kubectl get statefulsets -o jsonpath='{.items[*].metadata.name}')

for DEPLOYMENT in $DEPLOYMENTS; do
  NODE_SELECTOR=$(kubectl get deployment "$DEPLOYMENT" -o jsonpath='{.spec.template.spec.nodeSelector}')
  if [[ -z "$NODE_SELECTOR" ]]; then
    echo -e "${RED}Deployment '$DEPLOYMENT' does not have a node selector.${NC}"
  else
    echo -e "${GREEN}Deployment '$DEPLOYMENT' has node selector: $NODE_SELECTOR${NC}"
    for GKE_NODE_LABEL in "${GKE_NODE_LABELS[@]}"; do
      if [[ "$NODE_SELECTOR" == *"$GKE_NODE_LABEL"* ]]; then
        USE_GKE_NODE_LABEL_DEPLOYMENTS+=("$DEPLOYMENT")
      fi
    done
  fi
done

echo -e "${BLUE}Deployments using GKE node labels:${NC}"
if [[ ${#USE_GKE_NODE_LABEL_DEPLOYMENTS[@]} -eq 0 ]]; then
  echo -e "${BLUE}No Deployments found using GKE node labels.${NC}"
else
  for DEPLOYMENT in "${USE_GKE_NODE_LABEL_DEPLOYMENTS[@]}"; do
    echo -e "${BLUE}$DEPLOYMENT${NC}"
  done
fi

for STATEFULSET in $STATEFULESETS; do
  NODE_SELECTOR=$(kubectl get statefulset "$STATEFULSET" -o jsonpath='{.spec.template.spec.nodeSelector}')
  if [[ -z "$NODE_SELECTOR" ]]; then
    echo -e "${RED}StatefulSet '$STATEFULSET' does not have a node selector.${NC}"
  else
    echo -e "${GREEN}StatefulSet '$STATEFULSET' has node selector: $NODE_SELECTOR${NC}"
    for GKE_NODE_LABEL in "${GKE_NODE_LABELS[@]}"; do
      if [[ "$NODE_SELECTOR" == *"$GKE_NODE_LABEL"* ]]; then
        USE_GKE_NODE_LABEL_STATEFULSETS+=("$STATEFULSET")
      fi
    done
  fi
done
echo -e "${BLUE}StatefulSets using GKE node labels:${NC}"
if [[ ${#USE_GKE_NODE_LABEL_STATEFULSETS[@]} -eq 0 ]]; then
  echo -e "${BLUE}No StatefulSets found using GKE node labels.${NC}"
else
  for STATEFULSET in "${USE_GKE_NODE_LABEL_STATEFULSETS[@]}"; do
    echo -e "${BLUE}$STATEFULSET${NC}"
  done
fi
