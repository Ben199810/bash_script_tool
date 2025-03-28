#!/bin/bash

source ../modules/default.sh
source ../modules/kafka_vm_setting.sh

# 獲取所有 topic
TOPICS=$($KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server ${BOOTSTRAP_SERVER})

# 檢查是否有任何 topic
if [ -z "$TOPICS" ]; then
  echo "沒有可刪除的 Kafka topics。"
  exit 0
fi

echo "即將刪除以下 Kafka topics:"
echo "$TOPICS"

# 批次刪除所有 topic
for TOPIC in $TOPICS; do
  $KAFKA_HOME/bin/kafka-topics.sh --delete --topic $TOPIC --bootstrap-server ${BOOTSTRAP_SERVER}

  # 檢查刪除操作是否成功
  if [ $? -eq 0 ]; then
    echo "Kafka topic '$TOPIC' 已成功刪除。"
  else
    echo "刪除 Kafka topic '$TOPIC' 失敗。"
  fi
done