# 獲取 Memorystore 實例列表
function get_memorystore_instances() {
    read -rp "請輸入 Memorystore 的區域 (預設asia-east1): " MEMORYSTORE_REGION
    MEMORYSTORE_REGION=${MEMORYSTORE_REGION:-asia-east1}

    echo -e "${BLUE}正在列出所有 Memorystore 實例...${NC}"
    MEMORYSTORE_INSTANCES=$(gcloud redis instances list --region="$MEMORYSTORE_REGION" --format="table[no-heading](INSTANCE_NAME,REGION,HOST,PORT,STATUS)")
}

# 使用 fzf 選擇 Memorystore 實例
function select_memorystore_instance() {
    get_memorystore_instances
    if [ -z "$MEMORYSTORE_INSTANCES" ]; then
        echo -e "${RED}沒有可用的 Memorystore 實例。${NC}"
        exit 1
    fi

    SELECTED_MEMORYSTORE_INSTANCE=$(echo "$MEMORYSTORE_INSTANCES" | fzf --header="選擇要連線的 Memorystore 實例:" --prompt="Memorystore 實例: ")
}

# 獲取所有區域的 Memorystore 實例（不需要輸入區域）
function get_all_memorystore_instances() {
    echo -e "${BLUE}正在列出所有區域的 Memorystore 實例...${NC}"
    
    # 獲取所有可用的區域
    local regions=$(gcloud compute regions list --format="value(name)")
    
    # 初始化空的實例列表
    MEMORYSTORE_INSTANCES=""
    
    for region in $regions; do
        echo -e "${YELLOW}檢查區域: $region${NC}"
        local instances=$(gcloud redis instances list --region="$region" --format="table[no-heading](INSTANCE_NAME,REGION,HOST,PORT,STATUS)" 2>/dev/null)
        
        if [ ! -z "$instances" ]; then
            if [ -z "$MEMORYSTORE_INSTANCES" ]; then
                MEMORYSTORE_INSTANCES="$instances"
            else
                MEMORYSTORE_INSTANCES="$MEMORYSTORE_INSTANCES\n$instances"
            fi
        fi
    done
}

# 顯示 Memorystore 實例的詳細資訊
function show_memorystore_details() {
    local instance_name="$1"
    local region="$2"
    
    if [ -z "$instance_name" ] || [ -z "$region" ]; then
        echo -e "${RED}錯誤: 需要提供實例名稱和區域${NC}"
        return 1
    fi
    
    echo -e "${BLUE}正在獲取 Memorystore 實例詳細資訊...${NC}"
    gcloud redis instances describe "$instance_name" --region="$region"
}

# 可選擇列出指定區域或所有區域的實例
function list_memorystore_instances() {
  local operation_array=(
    "列出指定區域的 Memorystore 實例"
    "列出所有區域的 Memorystore 實例"
  )
  
  local operation=$(printf "%s\n" "${operation_array[@]}" | fzf --header="選擇操作:" --prompt="操作: ")
  
  case $operation in
    "列出指定區域的 Memorystore 實例")
      get_memorystore_instances
      if [ -n "$MEMORYSTORE_INSTANCES" ]; then
        echo -e "${GREEN}Memorystore 實例列表:${NC}"
        echo -e "實例名稱\t區域\t主機\t端口\t狀態"
        echo -e "----------------------------------------"
        echo -e "$MEMORYSTORE_INSTANCES"
      else
        echo -e "${YELLOW}在區域 $MEMORYSTORE_REGION 中沒有找到 Memorystore 實例。${NC}"
      fi
      ;;
    "列出所有區域的 Memorystore 實例")
      get_all_memorystore_instances
      if [ -n "$MEMORYSTORE_INSTANCES" ]; then
        echo -e "${GREEN}所有區域的 Memorystore 實例列表:${NC}"
        echo -e "實例名稱\t區域\t主機\t端口\t狀態"
        echo -e "----------------------------------------"
        echo -e "$MEMORYSTORE_INSTANCES"
      else
        echo -e "${YELLOW}沒有找到任何 Memorystore 實例。${NC}"
      fi
      ;;
  esac
}

# 解析選中的 Memorystore 實例資訊
function parse_selected_memorystore() {
    if [ -z "$SELECTED_MEMORYSTORE_INSTANCE" ]; then
        echo -e "${RED}沒有選擇任何 Memorystore 實例。${NC}"
        return 1
    fi
    
    MEMORYSTORE_NAME=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $1}')
    MEMORYSTORE_REGION=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $2}')
    MEMORYSTORE_HOST=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $3}')
    MEMORYSTORE_PORT=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $4}')
    MEMORYSTORE_STATUS=$(echo "$SELECTED_MEMORYSTORE_INSTANCE" | awk '{print $5}')
    
    echo -e "${GREEN}選中的 Memorystore 實例:${NC}"
    echo -e "  名稱: $MEMORYSTORE_NAME"
    echo -e "  區域: $MEMORYSTORE_REGION"
    echo -e "  主機: $MEMORYSTORE_HOST"
    echo -e "  端口: $MEMORYSTORE_PORT"
    echo -e "  狀態: $MEMORYSTORE_STATUS"
}