#!/bin/bash
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

POD_LIST=""

function get_all_pods() {
  local NAMESPACE_OPTION=$(get_namespace_option)
  POD_LIST=$(kubectl get pods $NAMESPACE_OPTION --no-headers 2>/dev/null)
}

function get_pod_status() {
  local NAMESPACE
  local POD_NAME
  local READY
  local STATUS
  local RESTARTS

  echo -e "${BLUE}🔍 POD 詳細資訊:${NC}"
  if is_query_all_namespaces; then
    echo "$POD_LIST" | while read -r LINE; do
      NAMESPACE=$(echo "$LINE" | awk '{print $1}')
      POD_NAME=$(echo "$LINE" | awk '{print $2}')
      READY=$(echo "$LINE" | awk '{print $3}')
      STATUS=$(echo "$LINE" | awk '{print $4}')
      RESTARTS=$(echo "$LINE" | awk '{print $5}')

      echo -e "${GREEN}📋 POD 名稱:${NC} $POD_NAME"
      echo -e "${GREEN}📂 命名空間:${NC} $NAMESPACE"
      echo -e "${GREEN}✅ 就緒狀態:${NC} $READY"
      echo -e "${GREEN}📊 狀態:${NC} $STATUS"
      echo -e "${GREEN}🔄 重啟次數:${NC} $RESTARTS"
      echo ""
    done
  else
    echo "$POD_LIST" | while read -r LINE; do
      POD_NAME=$(echo "$LINE" | awk '{print $1}')
      READY=$(echo "$LINE" | awk '{print $2}')
      STATUS=$(echo "$LINE" | awk '{print $3}')
      RESTARTS=$(echo "$LINE" | awk '{print $4}')

      echo -e "${GREEN}📋 POD 名稱:${NC} $POD_NAME"
      echo -e "${GREEN}✅ 就緒狀態:${NC} $READY"
      echo -e "${GREEN}📊 狀態:${NC} $STATUS"
      echo -e "${GREEN}🔄 重啟次數:${NC} $RESTARTS"
      echo ""
    done
  fi
}