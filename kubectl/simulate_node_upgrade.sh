#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh.sh

# 這個腳本會模擬 Kubernetes 節點的升級過程
kubectl get nodes -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp,VERSION:.status.nodeInfo.kubeletVersion'
echo "請選擇要升級的節點："
read -p "請輸入節點名稱：" node_name
# 確認節點名稱是否正確
if [[ -z "$node_name" ]]; then
  echo "節點名稱不能為空！"
  exit 1
fi
# 確認節點是否存在
node_exists=$(kubectl get nodes | grep "$node_name")
if [[ -z "$node_exists" ]]; then
  echo "節點 $node_name 不存在！"
  exit 1
fi

kubectl cordon $node_name
kubectl drain $node_name --ignore-daemonsets --delete-emptydir-data

sleep 300

# 復原
kubectl uncordon $node_name