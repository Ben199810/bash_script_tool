# 請設置以下環境變數
KAFKA_HOME=/root/kafka_2.13-3.8.0
# read -p "Kafka 安裝目錄: " KAFKA_HOME
# 檢查 KAFKA_HOME 環境變數是否設置
if [ -z "$KAFKA_HOME" ]; then
  echo "KAFKA_HOME 環境變數未設置。請設置該變數指向你的 Kafka 安裝目錄。"
  exit 1
fi

# betlog
BOOTSTRAP_SERVER=10.6.4.17:9092,10.6.4.69:9092,10.6.4.116:9092
# read -p "bootstrap-server: " BOOTSTRAP_SERVER
# 檢查 BOOTSTRAP_SERVER 環境變數是否設置
if [ -z "$BOOTSTRAP_SERVER" ]; then
  echo "bootstrap-server 環境變數未設置。請設置該變數指向你的 Kafka 伺服器。"
  exit 1
fi