#!/bin/bash
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/kubernetes.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

function search_pdb(){
    local PDBS="$1"

    echo -e "${BLUE}🔍 搜尋包含 '$SEARCH_KEYWORD' 的 PDB...${NC}"
    echo ""

    local MATCHING_PDBS=$(echo "$PDBS" | grep -i "$SEARCH_KEYWORD")
    if [[ -z "$MATCHING_PDBS" ]]; then
        echo -e "${YELLOW}⚠️ 沒有找到包含 '$SEARCH_KEYWORD' 的 PDB${NC}"
        exit 0
    else
        echo -e "${GREEN}✅ 找到 $(echo "$MATCHING_PDBS" | wc -l) 個符合的 PDB:${NC}"
        echo ""
        display_pdb_details "$MATCHING_PDBS"
    fi
}

function display_pdb_details(){
    local PDBS="$1"

    if [[ -z "$PDBS" ]]; then
        echo -e "${YELLOW}⚠️ 沒有找到任何 PDB 詳細資訊${NC}"
        return
    fi

    echo -e "${BLUE}🔍 PDB 詳細資訊:${NC}"
    if is_query_all_namespaces; then
      echo "$PDBS" | while read -r LINE; do
          local NAMESPACE=$(echo "$LINE" | awk '{print $1}')
          local NAME=$(echo "$LINE" | awk '{print $2}')
          local MIN_AVAILABLE=$(echo "$LINE" | awk '{print $3}')
          local MAX_UNAVAILABLE=$(echo "$LINE" | awk '{print $4}')
          local ALLOWED_DISRUPTIONS=$(echo "$LINE" | awk '{print $5}')
          local AGE=$(echo "$LINE" | awk '{print $6}')

          # 使用 jq 獲取額外的狀態資訊
          local currentHealthy=$(kubectl get pdb "$NAME" -n "$NAMESPACE" -o json | jq '.status.currentHealthy')

          echo -e "${GREEN}📋 PDB 名稱:${NC} $NAME"
          echo -e "${BLUE}   命名空間:${NC} $NAMESPACE"
          echo -e "${BLUE}   最小可用:${NC} $MIN_AVAILABLE"
          echo -e "${BLUE}   最大不可用:${NC} $MAX_UNAVAILABLE"
          echo -e "${BLUE}   允許中斷:${NC} $ALLOWED_DISRUPTIONS"
          echo -e "${BLUE}   建立時間:${NC} $AGE"
          echo -e "${BLUE}   當前健康狀態:${NC} $currentHealthy"
          echo ""
      done
    else
      echo "$PDBS" | while read -r LINE; do
          local NAME=$(echo "$LINE" | awk '{print $1}')
          local MIN_AVAILABLE=$(echo "$LINE" | awk '{print $2}')
          local MAX_UNAVAILABLE=$(echo "$LINE" | awk '{print $3}')
          local ALLOWED_DISRUPTIONS=$(echo "$LINE" | awk '{print $4}')
          local AGE=$(echo "$LINE" | awk '{print $5}')

          # 使用 jq 獲取額外的狀態資訊
          local currentHealthy=$(kubectl get pdb "$NAME" -o json | jq '.status.currentHealthy')

          echo -e "${GREEN}📋 PDB 名稱:${NC} $NAME"
          echo -e "${BLUE}   最小可用:${NC} $MIN_AVAILABLE"
          echo -e "${BLUE}   最大不可用:${NC} $MAX_UNAVAILABLE"
          echo -e "${BLUE}   允許中斷:${NC} $ALLOWED_DISRUPTIONS"
          echo -e "${BLUE}   建立時間:${NC} $AGE"
          echo -e "${BLUE}   當前健康狀態:${NC} $currentHealthy"
          echo ""
      done
    fi
}