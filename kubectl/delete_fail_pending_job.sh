#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

# 取得 job COMPLETIONS = 0/1 的 jobs
JOBS=$(kubectl get jobs --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" | grep -E '0/1' | awk '{print $1}')

# 列出所有符合條件的 jobs
echo -e "${YELLOW}Jobs with COMPLETIONS = 0/1:${NC}"
for JOB in $JOBS; do
  echo "$JOB"
done

# 輸入確認刪除
read -p "Do you want to delete these jobs? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "Deletion cancelled."
  exit 0
else
  echo "${YELLOW}Deleting jobs...${NC}"
  # 刪除所有符合條件的 jobs
  for JOB in $JOBS; do
    kubectl delete job "$JOB" --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" &
  done
  # 等待所有背景執行的刪除操作完成
  wait
fi