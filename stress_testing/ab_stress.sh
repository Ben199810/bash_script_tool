#!/bin/bash
source ../modules/default.sh

# 此脚本用于运行 ab (Apache Benchmark) 工具进行压力测试
# 輸入需要測試的網址和請求數量
read -p "請輸入需要測試的網址 (例如 example.com/path): " url
read -p "HTTP 或 HTTPS (請輸入 http 或 https): " protocol
read -p "請輸入請求數量 (例如 100): " requests
read -p "請輸入並發數量 (例如 10): " concurrency
read -p "請輸入測試時間 (例如 60): " time

# 開始壓力測試
echo -e "${YELLOW}開始壓力測試...${NC}"

# 如果 請輸入請求數量 為空
if [ -z "$requests" ]; then
  ab -c $concurrency -t $time $protocol://$url
else
  ab -c $concurrency -n $requests -t $time $protocol://$url
fi
echo -e "${GREEN}壓力測試完成。${NC}"
