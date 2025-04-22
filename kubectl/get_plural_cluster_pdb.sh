#!/bin/bash
source ../modules/default.sh
source ../modules/kubectl_operate.s

ALL_KUBE_CONTEXTS=(
  "context1"
  "context2"
  "context3"
)

for CONTEXT in "${ALL_KUBE_CONTEXTS[@]}"; do
  get_all_pdb $CONTEXT
done