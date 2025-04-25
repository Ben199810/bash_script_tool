#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh
source ../modules/helm_operate.sh

read -p "check all namespace resources? (y/n): " check_all_namespace

if [[ "$check_all_namespace" == "y" ]]; then
  helm_list_all_namespace
else
  helm_list
fi
