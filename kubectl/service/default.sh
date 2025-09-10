#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

# 查詢 LoadBalancer 類型的 Service
function find_loadbalancer_services() {
  local SERVICES

  SERVICES=$(kubectl get services $NAMESPACE_OPTION $KUBE_CONTEXT_OPTION -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | "名稱: \(.metadata.name)  命名空間: \(.metadata.namespace)  LoadBalancer IP: \(.spec.loadBalancerIP)"')

  echo -e "${BLUE}=== Type 屬於 LoadBalancer 類型的 Service ===${NC}"
  echo -e "${GREEN}${SERVICES}${NC}"
  echo ""
}

function search_service(){
    local SERVICES="$1"

    echo -e "${BLUE}🔍 搜尋包含 '$SEARCH_KEYWORD' 的 Service...${NC}"
    echo ""

    local MATCHING_SERVICES=$(echo "$SERVICES" | grep -i "$SEARCH_KEYWORD")
    if [[ -z "$MATCHING_SERVICES" ]]; then
        echo -e "${YELLOW}⚠️ 沒有找到包含 '$SEARCH_KEYWORD' 的 Service${NC} \n"
    else
        echo -e "${GREEN}✅ 找到 $(echo "$MATCHING_SERVICES" | wc -l) 個符合的 Service:${NC}"
        echo ""
        display_service_details "$MATCHING_SERVICES"
    fi
}

function display_service_details(){
    local SERVICES="$1"

    if [[ -z "$SERVICES" ]]; then
        echo -e "${YELLOW}⚠️ 沒有找到任何 Service 詳細資訊${NC}"
        return
    fi

    echo -e "${BLUE}🔍 Service 詳細資訊:${NC}"
    echo ""
    if is_query_all_namespaces; then
      echo "$SERVICES" | while read -r LINE; do
          local NAMESPACE=$(echo "$LINE" | awk '{print $1}')
          local NAME=$(echo "$LINE" | awk '{print $2}')
          local TYPE=$(echo "$LINE" | awk '{print $3}')
          local CLUSTER_IP=$(echo "$LINE" | awk '{print $4}')
          local EXTERNAL_IP=$(echo "$LINE" | awk '{print $5}')
          local PORTS=$(echo "$LINE" | awk '{print $6}')
          local AGE=$(echo "$LINE" | awk '{print $7}')

          echo -e "${GREEN}📋 Service 名稱:${NC} $NAME"
          echo -e "${BLUE}   命名空間:${NC} $NAMESPACE"
          echo -e "${BLUE}   類型:${NC} $TYPE"
          echo -e "${BLUE}   Cluster IP:${NC} $CLUSTER_IP"
          echo -e "${BLUE}   External IP:${NC} $EXTERNAL_IP"
          echo -e "${BLUE}   端口:${NC} $PORTS"
          echo -e "${BLUE}   建立時間:${NC} $AGE"
          echo ""
      done
    else
      echo "$SERVICES" | while read -r LINE; do
          local NAME=$(echo "$LINE" | awk '{print $1}')
          local TYPE=$(echo "$LINE" | awk '{print $2}')
          local CLUSTER_IP=$(echo "$LINE" | awk '{print $3}')
          local EXTERNAL_IP=$(echo "$LINE" | awk '{print $4}')
          local PORTS=$(echo "$LINE" | awk '{print $5}')
          local AGE=$(echo "$LINE" | awk '{print $6}')

          echo -e "${GREEN}📋 Service 名稱:${NC} $NAME"
          echo -e "${BLUE}   類型:${NC} $TYPE"
          echo -e "${BLUE}   Cluster IP:${NC} $CLUSTER_IP"
          echo -e "${BLUE}   External IP:${NC} $EXTERNAL_IP"
          echo -e "${BLUE}   端口:${NC} $PORTS"
          echo -e "${BLUE}   建立時間:${NC} $AGE"
          echo ""
      done
    fi
}