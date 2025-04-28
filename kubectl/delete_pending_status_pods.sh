#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

# 取得 pod status 為 Pending 的 pods
PODS=$(kubectl get pods --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" --field-selector=status.phase=Pending -o jsonpath='{.items[*].metadata.name}')

# delete pending status pods
for POD in $PODS; do
  kubectl delete pod "$POD" --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" &
done

# 等待所有背景執行的刪除操作完成
wait