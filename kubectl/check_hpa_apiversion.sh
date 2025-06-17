#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

# 檢查 HPA 的 API 版本是否是 autoscaling/v2beta2
function check_hpa_apiversion() {
  echo -e "${BLUE}正在檢查所有 HPA 的 API 版本...${NC}"
  
  # 獲取所有 HPA 的名稱 (all namespaces)
  local HPAES
  HPAES=$(kubectl get hpa -A -o jsonpath='{range .items[*]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' 2>/dev/null)
  
  # 檢查是否獲取成功
  if [ $? -ne 0 ]; then
    echo -e "${RED}錯誤: 無法獲取 HPA 資源，請檢查 kubectl 連接${NC}"
    return 1
  fi
  
  # 檢查是否有 HPA 資源
  if [ -z "$HPAES" ]; then
    echo -e "${YELLOW}在當前集群中沒有找到任何 HPA 資源${NC}"
    return 0
  fi
  
  echo -e "${BLUE}找到的 HPA 資源:${NC}"
  echo -e "${BLUE}$HPAES${NC}"
  echo ""
  
  local deprecated_count=0
  local total_count=0
  
  # 使用 IFS 按換行符分隔
  local old_ifs="$IFS"
  IFS=$'\n'
  
  # 檢查每個 HPA 的 API 版本
  for HPA in $HPAES; do
      # 跳過空行
      if [ -z "$HPA" ]; then
        continue
      fi
      
      # 取得 HPA 的名稱和命名空間
      local HPA_NAME=$(echo "$HPA" | awk '{print $2}')
      local HPA_NAMESPACE=$(echo "$HPA" | awk '{print $1}')
      
      # 檢查解析是否成功
      if [ -z "$HPA_NAME" ] || [ -z "$HPA_NAMESPACE" ]; then
        echo -e "${YELLOW}警告: 無法解析 HPA 信息: $HPA${NC}"
        continue
      fi

      local API_VERSION
      API_VERSION=$(kubectl get hpa "$HPA_NAME" -n "$HPA_NAMESPACE" -o jsonpath='{.apiVersion}' 2>/dev/null)
      
      if [ $? -ne 0 ]; then
        echo -e "${YELLOW}警告: 無法獲取 HPA $HPA_NAME 的 API 版本${NC}"
        continue
      fi
      
      ((total_count++))
      
      if [[ "$API_VERSION" == "autoscaling/v2beta2" ]]; then
        echo -e "${RED}⚠️  HPA $HPA_NAME (namespace: $HPA_NAMESPACE) 使用已棄用的 API 版本: $API_VERSION${NC}"
        ((deprecated_count++))
      else
        echo -e "${GREEN}✅ HPA $HPA_NAME (namespace: $HPA_NAMESPACE) 使用正確的 API 版本: $API_VERSION${NC}"
      fi
  done
  
  # 恢復原始 IFS
  IFS="$old_ifs"
  
  # 顯示統計結果
  echo ""
  echo -e "${BLUE}=== 檢查結果統計 ===${NC}"
  echo -e "${BLUE}總共檢查的 HPA: $total_count${NC}"
  echo -e "${GREEN}使用正確 API 版本: $((total_count - deprecated_count))${NC}"
  echo -e "${RED}使用已棄用 API 版本: $deprecated_count${NC}"
  
  if [ $deprecated_count -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}建議: 請將使用 autoscaling/v2beta2 的 HPA 升級到 autoscaling/v2${NC}"
    return 1
  else
    echo -e "${GREEN}所有 HPA 都使用正確的 API 版本！${NC}"
    return 0
  fi
}

# 主程式執行
check_hpa_apiversion