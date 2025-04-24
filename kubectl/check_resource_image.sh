#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

# images 空陣列儲存所有的 image 名稱
images=()

# 檢查所有 resources 內所有的 container 使用的 image 名稱
options=("deployment" "statefulset" "daemonset" "cronjob" "exit")
PS3="選擇 Kubernetes Resource: "
# all namespace resources
read -p "check all namespace resources? (y/n): " check_all_namespace
select opt in "${options[@]}"; do
  case $opt in
    "deployment")
      echo -e "${BLUE}You chose to check Deployment.${NC}"
      option=${opt}
      ;;
    "statefulset")
      echo -e "${BLUE}You chose to check StatefulSet.${NC}"
      option=${opt}
      ;;
    "daemonset")
      echo -e "${BLUE}You chose to check DaemonSet.${NC}"
      option=${opt}
      ;;
    "cronjob")
      echo -e "${BLUE}You chose to check CronJob.${NC}"
      option=${opt}
      ;;
    "exit")
      echo -e "${RED}Exiting...${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option. Please try again.${NC}"
      exit 1
      ;;
  esac
  if [[ "$check_all_namespace" == "y" ]]; then
    RESOURCES_AND_NAMESPACES=$(kubectl get $option --context $CURRENT_CONTEXT -A -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.namespace}{"\n"}{end}')
    RESOURCES=($(echo "$RESOURCES_AND_NAMESPACES" | awk '{print $1}'))
    NAMESPACES=($(echo "$RESOURCES_AND_NAMESPACES" | awk '{print $2}'))
  else 
    # RESOURCES=$(kubectl get $option --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
    # RESOURCES 篩選出與 shark-* statefulset 有關的資源
    RESOURCES=$(kubectl get $option --context $CURRENT_CONTEXT -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | grep '^shark-')
    RESOURCES=($RESOURCES)
  fi
  break
done

for i in "${!RESOURCES[@]}"; do
  # 將資源名稱和命名空間組合成一個字串
  if [[ "$check_all_namespace" == "y" ]]; then
    RESOURCE="${RESOURCES[$i]}"
    NAMESPACE="${NAMESPACES[$i]}"
    echo -e "${BLUE}Selected ${option}: $RESOURCE in namespace: $NAMESPACE${NC}"
    # cronJob 需要使用 jsonpath 來取得 spec.jobTemplate.spec.template.spec.containers.image
    if [[ "$option" == "cronJob" ]]; then
      CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $NAMESPACE -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[*].image}')
    else
      CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
    fi
  else
    RESOURCE="${RESOURCES[$i]}"
    echo -e "${BLUE}Selected ${option}: $RESOURCE${NC}"
    # cronJob 需要使用 jsonpath 來取得 spec.jobTemplate.spec.template.spec.containers.image
    if [[ "$option" == "cronJob" ]]; then
      CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[*].image}')
    else
      CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
      echo -e "Images: $CONTAINER_IMAGES"
    fi
  fi
  # 將 image 名稱加入 images 陣列
  for CONTAINER_IMAGE in $CONTAINER_IMAGES; do
    images+=("$CONTAINER_IMAGE")
  done
done

# images 陣列不為空，篩選重複的 image 名稱
if [ ${#images[@]} -gt 0 ]; then
  # echo -e "${BLUE}Images found: ${NC}"
  # 使用 sort 和 uniq 來篩選重複的 image 名稱
  unique_images=($(printf "%s\n" "${images[@]}" | sort -u))
  # for image in "${unique_images[@]}"; do
  #   echo -e "${GREEN}$image${NC}"
  # done
  # 過濾跟 php & fluent 相關的 image
  unique_images=($(printf "%s\n" "${unique_images[@]}" | grep -v "php" | grep -v "fluent"))
else
  echo -e "${RED}No images found.${NC}"
fi

# # 如果 unique_images 沒有符合 prod-fe50e426 或 prod-latest 的 tag
# # 則顯示錯誤訊息
# for image in "${unique_images[@]}"; do
#   if [[ "$image" == *"prod-fe50e426"* || "$image" == *"prod-latest"* ]]; then
#     echo -e "${GREEN}Found prod-fe50e426 or prod-latest tag: $image${NC}"
#   else
#     echo -e "${RED}No prod-fe50e426 or prod-latest tag found in image: $image${NC}"
#   fi
# done