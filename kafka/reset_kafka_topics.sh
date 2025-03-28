#!/bin/bash

source ../modules/default.sh
source ../modules/kafka_vm_setting.sh

# 獲取所有 topic
TOPICS=$($KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server $BOOTSTRAP_SERVER)

# 檢查是否有任何 topic
if [ -z "$TOPICS" ]; then
  echo "沒有可刪除的 Kafka topics。"
  exit 0
fi

echo "即將刪除並重新創建以下 Kafka topics:"
echo "$TOPICS"

# 批次刪除並重新創建所有 topic
for TOPIC in $TOPICS; do
  $KAFKA_HOME/bin/kafka-topics.sh --delete --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER

  # 檢查刪除操作是否成功
  if [ $? -eq 0 ]; then
    echo "Kafka topic '$TOPIC' 已成功刪除。"
  else
    echo "刪除 Kafka topic '$TOPIC' 失敗。"
    continue
  fi

  # 重新創建 topic 並設置分區數量為 1
  $KAFKA_HOME/bin/kafka-topics.sh --create --topic $TOPIC --bootstrap-server $BOOTSTRAP_SERVER --partitions 1 --replication-factor 1

  # 檢查創建操作是否成功
  if [ $? -eq 0 ]; then
    echo "Kafka topic '$TOPIC' 已成功重新創建，分區數量為 1。"
  else
    echo "重新創建 Kafka topic '$TOPIC' 失敗。"
  fi
done