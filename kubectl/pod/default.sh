#!/bin/bash
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

function display_pod_details() {
  local PODS="$1"

  echo -e "${BLUE}🔍 POD 詳細資訊:${NC}"
  if is_query_all_namespaces; then
    echo "$PODS" | while read -r LINE; do
      local NAMESPACE=$(echo "$LINE" | awk '{print $1}')
      local POD_NAME=$(echo "$LINE" | awk '{print $2}')
      local READY=$(echo "$LINE" | awk '{print $3}')
      local STATUS=$(echo "$LINE" | awk '{print $4}')
      local RESTARTS=$(echo "$LINE" | awk '{print $5}')

      echo -e "${GREEN}📋 POD 名稱:${NC} $POD_NAME"
      echo -e "${GREEN}📂 命名空間:${NC} $NAMESPACE"
      echo -e "${GREEN}✅ 就緒狀態:${NC} $READY"
      echo -e "${GREEN}📊 狀態:${NC} $STATUS"
      echo -e "${GREEN}🔄 重啟次數:${NC} $RESTARTS"
      echo ""
    done
  else
    echo "$PODS" | while read -r LINE; do
      local POD_NAME=$(echo "$LINE" | awk '{print $1}')
      local READY=$(echo "$LINE" | awk '{print $2}')
      local STATUS=$(echo "$LINE" | awk '{print $3}')
      local RESTARTS=$(echo "$LINE" | awk '{print $4}')

      echo -e "${GREEN}📋 POD 名稱:${NC} $POD_NAME"
      echo -e "${GREEN}✅ 就緒狀態:${NC} $READY"
      echo -e "${GREEN}📊 狀態:${NC} $STATUS"
      echo -e "${GREEN}🔄 重啟次數:${NC} $RESTARTS"
      echo ""
    done
  fi
}