#!/bin/bash
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"



function display_ingress_details() {
  local INGRESSES="$1"
  echo -e "${BLUE}=== Ingress 詳細資訊 ===${NC}"
  if is_query_all_namespaces; then
    echo "$INGRESSES" | while read -r LINE; do
      local NAMESPACE=$(echo "$LINE" | awk '{print $1}')
      local NAME=$(echo "$LINE" | awk '{print $2}')
      local CLASS=$(echo "$LINE" | awk '{print $3}')
      local HOSTS=$(echo "$LINE" | awk '{print $4}')
      local ADDRESS=$(echo "$LINE" | awk '{print $5}')

      echo -e "${GREEN}📋 Ingress 名稱:${NC} $NAME"
      echo -e "${GREEN}📂 命名空間:${NC} $NAMESPACE"
      echo -e "${GREEN}📋 所屬類別:${NC} $CLASS"
      echo -e "${GREEN} Hosts:${NC} $HOSTS"
      echo -e "${GREEN}📋 Address:${NC} $ADDRESS"
      echo ""
    done
  else
    echo "$INGRESSES" | while read -r LINE; do
      local NAME=$(echo "$LINE" | awk '{print $1}')
      local CLASS=$(echo "$LINE" | awk '{print $2}')
      local HOSTS=$(echo "$LINE" | awk '{print $3}')
      local ADDRESS=$(echo "$LINE" | awk '{print $4}')

      echo -e "${GREEN}📋 Ingress 名稱:${NC} $NAME"
      echo -e "${GREEN}📋 所屬類別:${NC} $CLASS"
      # 已知問題待解決：當 HOSTS 欄位過長時，輸出會被截斷
      echo -e "${GREEN} Hosts:${NC} $HOSTS"
      echo -e "${GREEN}📋 Address:${NC} $ADDRESS"
      echo ""
    done
  fi
}