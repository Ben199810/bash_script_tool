#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/../../modules/default.sh"
source "$DIR/../../modules/switch_gcp_project.sh"

switch_gcp_project_interface

get_running_gce_instances() {
  echo -e "${BLUE}正在列出所有運行中的 GCE 實例...${NC}"

  RUNNING_INSTANCES=$(gcloud compute instances list --filter="status=RUNNING" --format="table[no-heading](name,zone,INTERNAL_IP,EXTERNAL_IP,status)")
}

select_gce_instance() {
  get_running_gce_instances

  if [ -z "$RUNNING_INSTANCES" ]; then
    echo -e "${RED}沒有運行中的 GCE 實例。${NC}"
    exit 1
  fi

  SELECTED_INSTANCE=$(echo "$RUNNING_INSTANCES" | fzf --header="選擇要連線的 GCE 實例:" --prompt="GCE 實例: ")
}

get_memorystore_instances() {
  read -rp "請輸入 Memorystore 的區域 (預設asia-east1): " MEMORYSTORE_REGION
  MEMORYSTORE_REGION=${MEMORYSTORE_REGION:-asia-east1}

  echo -e "${BLUE}正在列出所有 Memorystore 實例...${NC}"
  MEMORYSTORE_INSTANCES=$(gcloud redis instances list --region="$MEMORYSTORE_REGION" --format="table[no-heading](INSTANCE_NAME,REGION,HOST,PORT,STATUS)")
}

select_memorystore_instance() {
  get_memorystore_instances
  if [ -z "$MEMORYSTORE_INSTANCES" ]; then
    echo -e "${RED}沒有可用的 Memorystore 實例。${NC}"
    exit 1
  fi

  SELECTED_MEMORYSTORE_INSTANCE=$(echo "$MEMORYSTORE_INSTANCES" | fzf --header="選擇要連線的 Memorystore 實例:" --prompt="Memorystore 實例: ")
}

start_iap_tunnel() {
  select_gce_instance
  if [ -z "$SELECTED_INSTANCE" ]; then
    echo -e "${RED}沒有選擇任何 GCE 實例。${NC}"
    exit 1
  fi

  local INSTANCE_NAME=$(echo "$SELECTED_INSTANCE" | awk '{print $1}')
  local ZONE=$(echo "$SELECTED_INSTANCE" | awk '{print $2}')

  echo -e "${GREEN}正在啟動 IAP 隧道連線到實例: $INSTANCE_NAME...${NC}"
  gcloud compute ssh "$INSTANCE_NAME" --zone="$ZONE" --tunnel-through-iap
}

use_iap_tunnel_port_forwarding_memorystore () {
  select_gce_instance
  select_memorystore_instance
  local JUMP_INSTANCE_NAME=$(echo "$SELECTED_INSTANCE" | awk '{print $1}')
  local JUMP_ZONE=$(echo "$SELECTED_INSTANCE" | awk '{print $2}')
  local MEMORYSTORE_INSTANCE_HOST=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $3}')
  local MEMORYSTORE_INSTANCE_PORT=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $4}')

  read -rp "請輸入本地要綁定的 port (預設6379): " LOCAL_PORT
  LOCAL_PORT=${LOCAL_PORT:-6379}

  echo -e "${BLUE}正在透過 IAP 隧道連線到跳板機 $JUMP_INSTANCE_NAME ($JUMP_ZONE)，本地 port $LOCAL_PORT 會對應到 $MEMORYSTORE_INSTANCE_HOST:$MEMORYSTORE_INSTANCE_PORT ...${NC}"

  gcloud compute ssh "$JUMP_INSTANCE_NAME" --zone="$JUMP_ZONE" --tunnel-through-iap -- -N -L "$LOCAL_PORT:$MEMORYSTORE_INSTANCE_HOST:$MEMORYSTORE_INSTANCE_PORT"
}

ask_user_and_connect() {
  local OPERATION_ARRAY=(
    "連線到該 GCE 內"
    "透過跳板機 port-forward Memorystore"
  )
  OPERATION=$(printf "%s\n" "${OPERATION_ARRAY[@]}" | fzf --header="選擇連線方式:" --prompt="連線方式: ")

  case $OPERATION in
    "連線到該 GCE 內")
      start_iap_tunnel
      ;;
    "透過跳板機 port-forward Memorystore")
      use_iap_tunnel_port_forwarding_memorystore
      ;;
  esac
}

ask_user_and_connect