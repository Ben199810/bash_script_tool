#!/bin/bash

source ../modules/default.sh
source ../modules/switch_kubernetes_context.sh

# 檢查 HPA 的 API 版本是否是 autoscaling/v2beta2
function check_hpa_apiversion() {
  # 獲取所有 HPA 的名稱 (all namespaces)
  HPAES=$(kubectl get hpa -A -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}')
  echo -e "${BLUE}All HPA: \n$HPAES${NC}"

  # 使用 IFS 按換行符分隔
  IFS=$'\n'
  # 檢查每個 HPA 的 API 版本
  for HPA in $HPAES; do
      # 取得 HPA 的名稱和命名空間
      HPA_NAME=$(echo $HPA | awk '{print $2}')
      HPA_NAMESPACE=$(echo $HPA | awk '{print $1}')

      API_VERSION=$(kubectl get hpa "$HPA_NAME" -n $HPA_NAMESPACE -o jsonpath='{.apiVersion}')
      if [[ "$API_VERSION" == "autoscaling/v2beta2" ]]; then
        echo -e "${RED}HPA $HPA_NAME is using API version: $API_VERSION${NC}"
      else
        echo -e "${GREEN}HPA $HPA_NAME is using the correct API version: $API_VERSION${NC}"
      fi
  done
  # 恢復原始 IFS
  unset IFS
}

check_hpa_apiversion