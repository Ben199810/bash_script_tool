#!/bin/bash

# 取得當前時間
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# 輸入要測試的網址跟路徑
read -p "請輸入要測試的網址跟路徑: " url

# 選擇 http 或 https
read -p "請選擇 http 或 https (預設為 http): " protocol
if [ -z "$protocol" ]; then
  protocol="http"
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
