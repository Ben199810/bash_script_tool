#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  # 切換 Kubernetes context
  switch_context_interface
  # 詢問是否查詢所有命名空間
  ask_query_all_namespaces
  # 獲取所有 POD 的狀態
  get_all_pods
  display_pod_details "$POD_LIST"
}

main