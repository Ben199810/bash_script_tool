# 驗證 IP 地址格式
# 參數：$1 - IP 地址
# 返回：0=有效, 1=無效, 2=缺少參數
function validate_ip() {
  local ip=$1
  
  if [ -z "$ip" ]; then
    echo -e "${RED}錯誤：缺少 IP 參數${NC}" >&2
    return 2
  fi
  
  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    return 0
  else
    return 1
  fi
}

# 在當前專案中搜尋 IP 地址
# 檢查靜態 IP、GCE 實例和轉發規則
function find_ip_in_project() {
  local search_ip
  
  echo -e "${YELLOW}請輸入要搜尋的 IP 位址:${NC}"
  read -p "IP: " search_ip
  
  if ! validate_ip "$search_ip"; then
    echo -e "${RED}無效的 IP 位址格式${NC}"
    return 1
  fi

  echo -e "${BLUE}正在搜尋 IP: $search_ip${NC}"
  
  # 搜尋靜態 IP
  echo -e "${CYAN}檢查靜態 IP 地址...${NC}"
  gcloud compute addresses list --filter="address=$search_ip" --format="table(name, address, region, status)"
  
  # 搜尋實例
  echo -e "${CYAN}檢查 GCE 實例...${NC}"
  gcloud compute instances list --filter="networkInterfaces[].networkIP=$search_ip OR networkInterfaces[].accessConfigs[].natIP=$search_ip" --format="table(name, zone, networkInterfaces[].networkIP, networkInterfaces[].accessConfigs[].natIP)"
  
  # 搜尋轉發規則
  echo -e "${CYAN}檢查轉發規則...${NC}"
  gcloud compute forwarding-rules list --filter="IPAddress=$search_ip" --format="table(name, region, IPAddress, target)"
}