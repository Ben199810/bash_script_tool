#!/bin/bash
source ../modules/switch_kubernetes_context.sh

switch_context_interface # 切換 Kubernetes Context 和 Namespace 的介面實作

# 定義常數

# DEV/QA 環境
readonly DEV_QA_FILESTORE_IP="172.18.0.106"
readonly DEV_CONTEXT="gke_gcp-20220425-004_asia-east1-b_bbin-interface-dev"
readonly QA_CONTEXT="gke_gcp-20220425-005_asia-east1-b_bbin-interface-qa"
# STAGING 環境的檔案系統 IP
readonly STAGING_TXT_FILESTORE_IP="172.18.2.50"
readonly STAGING_AIO_TXT_FILESTORE_IP="172.18.2.186"
readonly STAGING_AH_TXT_FILESTORE_IP="172.18.3.18"
readonly STAGING_CONTEXT="gke_gcp-20240131-024_asia-east1_bbin-interface-staging"
# PROD 環境的檔案系統 IP
readonly PROD_TXT_FILESTORE_IP="172.18.2.130"
readonly PROD_AIO_TXT_FILESTORE_IP="172.18.2.66"
readonly PROD_AH_TXT_FILESTORE_IP="172.18.2.194"
readonly PROD_CONTEXT="gke_gcp-20220425-006_asia-east1_bbin-interface-prod"



# 對 Pod 使用客製化的 df 指令，獲取想要的資訊
pod_df() {
  local POD="$1"
  local CONTAINER_NAME="$2"

  # 檢查是否有找到符合條件的 Pod，如果沒有找到，則輸出提示信息並返回錯誤碼
  if [ -z "$POD" ]; then
    echo -e "${YELLOW}無法找到符合搜尋條件的 Pod 在命名空間 $CURRENT_NAMESPACE 中${NC}"
    return 1
  fi

  echo -e "${CYAN}📊 檢查 Pod: $POD${NC}"
  echo -e "${GREEN}💽 磁碟使用情況:${NC}"
  # 檢查當前上下文是否為指定的環境
  if [[ $CURRENT_CONTEXT == "$QA_CONTEXT" || $CURRENT_CONTEXT == "$DEV_CONTEXT" ]]; then
    kubectl exec --context="$CURRENT_CONTEXT" -n "$CURRENT_NAMESPACE" "$POD" -c "$CONTAINER_NAME" -- df -h | awk '
    /^'"${DEV_QA_FILESTORE_IP}"'/ {
      filesystem = $0
      getline
      print "Filesystem:", filesystem, "Used:", $2, "Available:", $3, "Use%:", $4, "Mountpoint:", $5
    }'
  elif [[ $CURRENT_CONTEXT == "$STAGING_CONTEXT" ]]; then
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
  elif [[ $CURRENT_CONTEXT == "$PROD_CONTEXT" ]]; then
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
}

get_random_pod() {
  AIO_WEB_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep aio-web-ball-member | grep -v nginx-proxy | shuf -n 1)
  AIO_API_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep aio-api-ball-member | grep -v nginx-proxy | shuf -n 1)
  BALL_MEMBER_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ball-member | grep -v nginx-proxy | grep -v aio | grep -v bg | shuf -n 1)
  BAMBI_OFFERCENTER_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep bambi-offercenter | shuf -n 1)
  INTERNAL_BLISSEY_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep internal-blissey | shuf -n 1)
  CTL_BLISSEY_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ctl-blissey | shuf -n 1)
  HALL_BLISSEY_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep hall-blissey | shuf -n 1)
  EAGLE_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep eagle | shuf -n 1)
  WOLF_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep wolf | shuf -n 1)
  IPL_CTL_BACKGROUND_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep ipl-ctl-background | shuf -n 1)
  CHECK_INFO_POD=$(kubectl get pod -n $CURRENT_NAMESPACE --no-headers -o 'custom-columns=NAME:.metadata.name' | grep checkinfo | shuf -n 1)
}

check_pod_readwrite_volumeMount() {
  local POD="$1"
  local CONTAINER_NAME="$2"
  
  # 檢查參數
  if [ -z "$POD" ]; then
    echo -e "$無法找到符合搜尋條件的 Pod 在命名空間 $CURRENT_NAMESPACE 中${NC}"
    return 1
  fi
  
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║                     📋 Pod Volume 配置檢查報告                                  ║${NC}"
  echo -e "${CYAN}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
  echo -e "${CYAN}║ Pod 名稱: ${YELLOW}$POD${NC}"
  echo -e "${CYAN}║ 容器名稱: ${YELLOW}$CONTAINER_NAME${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
  
  echo ""
  echo -e "${GREEN}📁 Volume Mounts 掛載點:${NC}"
  kubectl get pod "$POD" -n "$CURRENT_NAMESPACE" -o json | jq -r --arg CONTAINER_NAME "$CONTAINER_NAME" '.spec.containers[] | select(.name == $CONTAINER_NAME) | (.volumeMounts[]? | "  🔗 \(.mountPath) -> Volume: \(.name)")'
  
  echo ""
  echo -e "${GREEN}💾 Persistent Volume Claims:${NC}"
  kubectl get pod "$POD" -n "$CURRENT_NAMESPACE" -o json | jq -r '.spec.volumes[]? | select(has("persistentVolumeClaim")) | "  📦 Volume: \(.name) -> PVC: \(.persistentVolumeClaim.claimName)"'
  
  echo ""
  echo -e "${BLUE}────────────────────────────────────────────────────────────────────────────────${NC}"
}

# 檢查 Pod 的檔案系統使用情況
main() {
  get_random_pod
  echo -e "${YELLOW}🚀 開始檢查 Pod Volume 掛載和磁碟使用情況${NC}"
  echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════════════${NC}"
  # read-write
  pod_df "${EAGLE_POD}" "go"
  check_pod_readwrite_volumeMount "$EAGLE_POD" "go"
  echo ""
  pod_df "${WOLF_POD}" "go"
  check_pod_readwrite_volumeMount "$WOLF_POD" "go"
  echo ""
  pod_df "${IPL_CTL_BACKGROUND_POD}" "php"
  check_pod_readwrite_volumeMount "${IPL_CTL_BACKGROUND_POD}" "php"
  echo ""
  pod_df "${CTL_BLISSEY_POD}" "php"
  check_pod_readwrite_volumeMount "${CTL_BLISSEY_POD}" "php"
  echo ""
  pod_df "${HALL_BLISSEY_POD}" "php"
  check_pod_readwrite_volumeMount "${HALL_BLISSEY_POD}" "php"
  echo ""
  pod_df "${INTERNAL_BLISSEY_POD}" "php"
  check_pod_readwrite_volumeMount "${INTERNAL_BLISSEY_POD}" "php"
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
  echo -e "${YELLOW}✅ 檢查完成！${NC}"
}

main