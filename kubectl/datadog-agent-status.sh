#!/bin/bash
source ./switch_kubernetes_context.sh

# 檢查 datadog agent status 特定服務狀態使用關鍵字進行搜尋。

echo "Found pods:"
kubectl get pods -n datadog -o custom-columns=NAME:.metadata.name --no-headers | grep -v cluster
echo ""

read -p "搜尋關鍵字：" SEARCH_KEYWORD

PODS=$(kubectl get pods -n datadog -o custom-columns=NAME:.metadata.name --no-headers | grep -v cluster)

IFS=$'\n' read -d '' -r -a POD_ARRAY <<< "$PODS"
for POD in "${POD_ARRAY[@]}"; do
  echo "Checking status of pod: $POD"
  
  kubectl exec -n datadog $POD -c agent -- agent status | grep "$SEARCH_KEYWORD"
  if [ $? -ne 0 ]; then
    echo "No kafka-common found in $POD"
  fi
  echo "----------------------------------------"
done

echo "Finished checking all pods."
