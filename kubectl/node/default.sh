#!/bin/bash
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/switch_kubernetes_context.sh"

# 選擇節點（Node）
select_node() {
  NODE=$(kubectl get nodes --no-headers -o 'custom-columns=NAME:.metadata.name,STATUS:.status.conditions[-1].type,AGE:.metadata.creationTimestamp,VERSION:.status.nodeInfo.kubeletVersion' | fzf --prompt="選擇節點 (Node): ")
}

# 隔離節點，標註為不可調度狀態
cordon_node() {
  if [[ -n "$NODE" ]]; then
    kubectl cordon "$NODE"
    echo -e "${GREEN}✅ 已隔離節點：$NODE${NC}"
    echo ""
  else
    echo -e "${RED}⚠️ 無法隔離節點${NC}"
    echo ""
    exit 1
  fi
}

# 解除節點隔離，標註為可調度狀態
uncordon_node() {
  if [[ -n "$NODE" ]]; then
    kubectl uncordon "$NODE"
    echo -e "${GREEN}✅ 已解除節點隔離：$NODE${NC}"
    echo ""
  else
    echo -e "${RED}⚠️ 無法解除節點隔離${NC}"
    echo ""
    exit 1
  fi
}

# 驅逐節點工作負載
drain_node() {
  if [[ -n "$NODE" ]]; then
    kubectl drain "$NODE" --ignore-daemonsets --delete-local-data
    echo -e "${GREEN}✅ 已驅逐節點工作負載：$NODE${NC}"
    echo ""
  else
    echo -e "${RED}⚠️ 無法驅逐節點工作負載${NC}"
    echo ""
    exit 1
  fi
}