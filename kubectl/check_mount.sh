#!/bin/bash
source ./switch_kubernetes_context.sh

# 對 Pod 使用客製化的 df 指令，獲取想要的資訊
pod_df() {
  SEARCH_KEYWORD="$1"
  CONTAINER_NAME="$2"

  DEV_QA_FILESTORE_IP="172.18.0.106"

  STAGING_TXT_FILESTORE_IP="172.18.2.50"
  STAGING_AIO_TXT_FILESTORE_IP="172.18.2.186"
  STAGING_AH_TXT_FILESTORE_IP="172.18.3.18"

  PROD_TXT_FILESTORE_IP="172.18.2.130"
  PROD_AIO_TXT_FILESTORE_IP="172.18.2.66"
  PROD_AH_TXT_FILESTORE_IP="172.18.2.194"

  PODS=$(kubectl get pod --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" -o 'custom-columns=NAME:.metadata.name' | grep $SEARCH_KEYWORD)

  # 檢查是否有找到符合條件的 Pod，如果沒有則退出
  if [ -z "$PODS" ]; then
    echo "No pods found with keyword: $SEARCH_KEYWORD"
    exit 0
  fi

  for POD in $PODS; do
    echo -e "${BLUE}Checking pod: $POD${NC}"
    # 檢查當前上下文是否為指定的環境
    if [[ $CURRENT_CONTEXT == "gke_gcp-20220425-005_asia-east1-b_bbin-interface-qa" || $CURRENT_CONTEXT == "gke_gcp-20220425-004_asia-east1-b_bbin-interface-dev" ]]; then
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${DEV_QA_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
    elif [[ $CURRENT_CONTEXT == "gke_gcp-20240131-024_asia-east1_bbin-interface-staging" ]]; then
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${STAGING_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${STAGING_AIO_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${STAGING_AH_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
    elif [[ $CURRENT_CONTEXT == "gke_gcp-20220425-006_asia-east1_bbin-interface-prod" ]]; then
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${PROD_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${PROD_AIO_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
      kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
      /^'"${PROD_AH_TXT_FILESTORE_IP}"'/ {
        filesystem = $0
        getline
        print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
      }'
    else
      echo "Skipping pod $POD for context $CURRENT_CONTEXT as it is not in the specified environments."
    fi
  done
}

# 取得 deployment 複數的 Pod 名稱，隨機選擇一個 Pod
AIO_WEB_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep aio-web-ball-member | grep -v nginx-proxy | shuf -n 1)
AIO_API_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep aio-api-ball-member | grep -v nginx-proxy | shuf -n 1)
BALL_MEMBER_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ball-member | grep -v nginx-proxy | grep -v aio | grep -v bg | shuf -n 1)
BAMBI_OFFERCENTER_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep bambi-offercenter | shuf -n 1)
INTERNAL_BLISSEY_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep internal-blissey | shuf -n 1)
CTL_BLISSEY_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ctl-blissey | shuf -n 1)
HALL_BLISSEY_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep hall-blissey | shuf -n 1)
EAGLE_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep eagle | shuf -n 1)
WOLF_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep wolf | shuf -n 1)
IPL_CTL_BACKGROUND_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ipl-ctl-background | shuf -n 1)
CHECK_INFO_POD=$(kubectl get pod -n interface --no-headers -o 'custom-columns=NAME:.metadata.name' | grep checkinfo | shuf -n 1)



# 檢查 Pod 的檔案系統使用情況
# read-write
pod_df "${EAGLE_POD}" "go"
echo ""

pod_df "${WOLF_POD}" "go"
echo ""

pod_df "${IPL_CTL_BACKGROUND_POD}" "php"
echo ""

pod_df "${CTL_BLISSEY_POD}" "php"
echo ""

pod_df "${HALL_BLISSEY_POD}" "php"
echo ""

pod_df "${INTERNAL_BLISSEY_POD}" "php"
echo ""

# read-only
pod_df "${CHECK_INFO_POD}" "php"
echo ""

pod_df "${BAMBI_OFFERCENTER_POD}" "app"
echo ""

pod_df "${AIO_API_POD}" "php"
echo ""

pod_df "${AIO_WEB_POD}" "php"
echo ""

pod_df "${BALL_MEMBER_POD}" "php"