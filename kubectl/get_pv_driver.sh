#!/bin/bash
source ../modules/default.sh

# 顯示當前 kubernetes 的 context
CURRENT_CONTEXTS=$(kubectl config current-context)
echo -e "${BLUE}Current Kubernetes contexts: $CURRENT_CONTEXTS${NC}"

# 查看 kubernetes 所有 PV 的 Driver
ALL_PV_NAME=$(kubectl get pv -o "name")
echo -e "All Persistent Volumes: \n$ALL_PV_NAME"

for PV_NAME in $ALL_PV_NAME; do
  # 取得 PV 的 Type
  TYPE=$(kubectl describe $PV_NAME | grep "Type:" | awk '{print $2}')
  # 如果 TYPE 開頭是 NFS，則顯示 Server
  if [[ $TYPE == "NFS" ]]; then
    SERVER=$(kubectl describe $PV_NAME | grep "Server:" | awk '{print $2}')
    echo -e "${BLUE}Persistent Volume: $PV_NAME \nType: $TYPE \nServer: $SERVER${NC}"
    # 如果 SERVER 是 NFS，則顯示注意事項
    echo -e "${YELLOW}注意此 PV 還有在使用 Network File Storage，請確認是否還有使用${NC}"
  else
    # 如果 TYPE 不是 NFS，則顯示 Driver
    DRIVER=$(kubectl describe $PV_NAME | grep "Driver:" | awk '{print $2}')
    echo -e "${BLUE}Persistent Volume: $PV_NAME \nType: $TYPE \nDriver: $DRIVER${NC}"
    # 如果 DRIVER 是 filestore.csi.storage.gke.io，則顯示注意事項
    if [[ $DRIVER == "filestore.csi.storage.gke.io" ]]; then
      echo -e "${YELLOW}注意此 PV 還有在使用 Network File Storage，請確認是否還有使用${NC}"
    fi
  fi
done

echo -e "${GREEN}All Persistent Volumes and their Drivers displayed successfully.${NC}"
