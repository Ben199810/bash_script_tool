#!/bin/bash
source ../modules/default.sh

# 此脚本用于运行 ab (Apache Benchmark) 工具进行压力测试

# 使用者決定自行輸入或者使用腳本內預設值
read -p "是否使用預設值 (y/n): " use_default
if [ "$use_default" == "y" ]; then
  echo -e "${GREEN}使用預設值...${NC}"
  url=""
  protocol=https
  requests=50000
  concurrency=10
  time=600
  host=""
else
  # 輸入需要測試的網址和請求數量
  read -p "請輸入需要測試的網址 (例如 example.com/path): " url
  read -p "HTTP 或 HTTPS (請輸入 http 或 https): " protocol
  read -p "請輸入請求數量 (例如 100): " requests
  read -p "請輸入並發數量 (例如 10): " concurrency
  read -p "請輸入測試時間 (例如 60): " time
  read -p "如果測試網址是IP, 請輸入Host: " host
fi

# 開始壓力測試
echo -e "${YELLOW}開始壓力測試...${NC}"

# 如果 請輸入Host 為空
if [ -z "$host" ]; then
  # 如果 請輸入請求數量 為空
  if [ -z "$requests" ]; then
    echo -e "${BLUE}ab -c $concurrency -t $time $protocol://$url${NC}"
    ab -c $concurrency -t $time $protocol://$url
  else
    echo -e "${BLUE}ab -c $concurrency -n $requests -t $time $protocol://$url${NC}"
    ab -c $concurrency -n $requests -t $time $protocol://$url
  fi
else
  # 如果 請輸入請求數量 為空
  if [ -z "$requests" ]; then
    echo -e "${BLUE}ab -c $concurrency -t $time -H \"Host: $host\" $protocol://$url${NC}"
    ab -c $concurrency -t $time -H "Host: $host" $protocol://$url
  else
    echo -e "${BLUE}ab -c $concurrency -n $requests -t $time -H \"Host: $host\" $protocol://$url${NC}"
    ab -c $concurrency -n $requests -t $time -H "Host: $host" $protocol://$url
  fi
fi
echo -e "${GREEN}壓力測試完成。${NC}"
