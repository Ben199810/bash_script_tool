#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

simulate_node_upgrade() {
  echo -e "${BLUE}開始模擬節點升級流程${NC}"
  echo "請設定模擬升級的中斷時間："
  read -p "請輸入升級時間（秒，預設為300秒）：" upgrade_duration
  # 如果沒有輸入，使用預設值 300 秒
  if [[ -z "$upgrade_duration" ]]; then
    upgrade_duration=300
  fi
  # 驗證輸入是否為數字
  if ! [[ "$upgrade_duration" =~ ^[0-9]+$ ]]; then
    echo "錯誤：升級時間必須是正整數！"
    exit 1
  fi
  cordon_node
  drain_node
  echo -e "${BLUE}開始模擬節點升級，將等待 $upgrade_duration 秒...${NC}"
  sleep $upgrade_duration
  uncordon_node
  echo -e "${GREEN}✅ 節點升級模擬完成${NC}"
}

main () {
  ask_switch_context_interface
  select_node
  simulate_node_upgrade
}

main