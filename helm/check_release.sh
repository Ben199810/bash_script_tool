#!/bin/bash
source ../modules/helm_operate.sh
source ../kubectl/switch_kubernetes_context.sh

read -p "check all namespace resources? (y/n): " check_all_namespace

if [[ "$check_all_namespace" == "y" ]]; then
  helm_list_all_namespace
else
  helm_list
fi

HELM_RELEASES=($(helm list --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE --all-namespaces -o json | jq -r '.[] | "\(.name)"'))

