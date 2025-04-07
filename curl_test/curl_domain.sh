#!/bin/bash

# 使用者決定自行輸入或者使用腳本內預設值
read -p "是否使用預設值 (y/n): " use_default
if [ "$use_default" == "y" ]; then
  echo -e "${GREEN}使用預設值...${NC}"
  url="example.com/path"
  protocol="https"
else
  # 輸入需要測試的網址和請求數量
  read -p "請輸入需要測試的網址 (例如 example.com/path): " url
  read -p "HTTP 或 HTTPS (請輸入 http 或 https): " protocol
fi

# 迴圈測試網址
while true; do
  # 取得當前時間
  current_time=$(date "+%Y-%m-%d %H:%M:%S")
  # 使用 curl 測試網址
  response=$(curl -s -o /dev/null -w "%{http_code}" "$protocol://$url")
  # 判斷回應狀態碼
  if [ "$response" -eq 200 ]; then
    echo "[$current_time] $protocol://$url 回應正常 (狀態碼: $response)"
  else
    echo "[$current_time] $protocol://$url 回應異常 (狀態碼: $response)"
  fi
  # 等待一段時間後再測試
  sleep 3
done
