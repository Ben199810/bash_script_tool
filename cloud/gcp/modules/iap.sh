# 取得所有運行中的 GCE 實例
# 設定全域變數 RUNNING_INSTANCES
function get_running_gce_instances() {
  echo -e "${BLUE}正在列出所有運行中的 GCE 實例...${NC}"

  RUNNING_INSTANCES=$(gcloud compute instances list --filter="status=RUNNING" --format="table[no-heading](name,zone,INTERNAL_IP,EXTERNAL_IP,status)")
}

# 選擇 GCE 實例
# 設定全域變數 SELECTED_INSTANCE
function select_gce_instance() {
  get_running_gce_instances

  if [ -z "$RUNNING_INSTANCES" ]; then
    echo -e "${RED}沒有運行中的 GCE 實例。${NC}"
    exit 1
  fi

  SELECTED_INSTANCE=$(echo "$RUNNING_INSTANCES" | fzf --header="選擇要連線的 GCE 實例:" --prompt="GCE 實例: ")
}

# 透過 IAP 隧道連線到 GCE 實例
function start_iap_tunnel() {
  select_gce_instance
  
  if [ -z "$SELECTED_INSTANCE" ]; then
    echo -e "${RED}沒有選擇任何 GCE 實例。${NC}"
    exit 1
  fi

  local instance_name=$(echo "$SELECTED_INSTANCE" | awk '{print $1}')
  local zone=$(echo "$SELECTED_INSTANCE" | awk '{print $2}')

  echo -e "${GREEN}正在啟動 IAP 隧道連線到實例: $instance_name...${NC}"
  gcloud compute ssh "$instance_name" --zone="$zone" --tunnel-through-iap
}

# 透過跳板機 Port Forward 到 Memorystore
function use_iap_tunnel_port_forwarding_memorystore() {
  select_gce_instance
  select_memorystore_instance
  
  # 解析 GCE 實例資訊
  local jump_instance_name=$(echo "$SELECTED_INSTANCE" | awk '{print $1}')
  local jump_zone=$(echo "$SELECTED_INSTANCE" | awk '{print $2}')
  
  # 解析 Memorystore 資訊
  parse_selected_memorystore
  
  local local_port
  read -rp "請輸入本地要綁定的 port (預設6379): " local_port
  local_port=${local_port:-6379}

  echo -e "${BLUE}正在透過 IAP 隧道連線到跳板機 $jump_instance_name ($jump_zone)，本地 port $local_port 會對應到 $MEMORYSTORE_HOST:$MEMORYSTORE_PORT ...${NC}"

  gcloud compute ssh "$jump_instance_name" --zone="$jump_zone" --tunnel-through-iap -- -N -L "$local_port:$MEMORYSTORE_HOST:$MEMORYSTORE_PORT"
}