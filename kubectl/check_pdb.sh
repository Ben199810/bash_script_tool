#!/bin/bash
source ../modules/default.sh
source ../modules/kubectl_operate.sh

ALL_KUBE_CONTEXTS_AND_NAMESPACES=(
  "context1:namespace1"
  "context2:namespace2"
  "context3:namespace3"
)

for CONTEXT_AND_NAMESPACE in "${ALL_KUBE_CONTEXTS_AND_NAMESPACES[@]}"; do
   IFS=':' read -r KUBE_CONTEXT KUBE_NAMESPACE <<< "$CONTEXT_AND_NAMESPACE"
  describe_pdb $KUBE_CONTEXT $KUBE_NAMESPACE
done