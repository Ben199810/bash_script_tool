#!/bin/bash
source ../modules/default.sh
source ../modules/switch_kubernetes_context.sh
source ../modules/docker_operate.sh

# images 空陣列儲存所有的 image 名稱
images=()
new_images=()

# 檢查所有 resources 內所有的 container 使用的 image 名稱
# 如果有使用的 image 名稱開頭是 gcr.io 則顯示該 container 的資訊

options=("deployment" "statefulset" "cronJob" "exit")
PS3="選擇 Kubernetes Resource: "
select opt in "${options[@]}"; do
  case $opt in
    "deployment")
      echo -e "${BLUE}You chose to check Deployment.${NC}"
      RESOURCES=$(kubectl get deployment --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
      option=${opt}
      break
      ;;
    "statefulset")
      echo -e "${BLUE}You chose to check StatefulSet.${NC}"
      RESOURCES=$(kubectl get statefulset --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
      option=${opt}
      break
      ;;
    "cronJob")
      echo -e "${BLUE}You chose to check CronJob.${NC}"
      RESOURCES=$(kubectl get cronjob --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
      option=${opt}
      break
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
done

for RESOURCE in $RESOURCES; do
  echo -e "${BLUE}Selected ${option}: $RESOURCE${NC}"
  if [[ "$option" == "cronJob" ]]; then
    # cronJob 需要使用 jsonpath 來取得 spec.jobTemplate.spec.template.spec.containers.image
    CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[*].image}')
  else
  CONTAINER_IMAGES=$(kubectl get ${option} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
  fi
  for CONTAINER_IMAGE in $CONTAINER_IMAGES; do
    if [[ "$CONTAINER_IMAGE" == gcr.io/rd6-project/* ]]; then
      echo -e "${GREEN}Container Image: $CONTAINER_IMAGE${NC}"
      # 將 image 名稱加入 images 陣列
      images+=("$CONTAINER_IMAGE")
    fi
  done
done

# images 陣列不為空，篩選重複的 image 名稱
if [ ${#images[@]} -gt 0 ]; then
  echo -e "${BLUE}Images found: ${NC}"
  # 使用 sort 和 uniq 來篩選重複的 image 名稱
  unique_images=($(printf "%s\n" "${images[@]}" | sort -u))
  for image in "${unique_images[@]}"; do
    echo -e "${GREEN}$image${NC}"
    # gcr.io 字串替換 asia-east1-docker.pkg.dev/gcp-20210526-001
    new_image=$(echo "$image" | sed 's/gcr.io/asia-east1-docker.pkg.dev\/gcp-20210526-001/g')
    new_images+=("$new_image")
  done
else
  echo -e "${RED}No images found.${NC}"
fi

read -p "Do you want check new images? (y/n): " answer

if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  echo -e "${RED}Exiting...${NC}"
  exit 0
else
  # 檢查 new_images 陣列是否有新的 image 名稱
  if [ ${#new_images[@]} -gt 0 ]; then
    echo -e "${BLUE}New Images found: ${NC}"
    for new_image in "${new_images[@]}"; do
      echo -e "${GREEN}$new_image${NC}"
    done
  else
    echo -e "${RED}No new images found.${NC}"
  fi
fi

# # docker pull
# docker_pull "${unique_images[@]}"

# # docker tag
# docker_tag unique_images[@] new_images[@]

# # docker push
# docker_push "${new_images[@]}"

# # docker rmi
# docker_rmi "${unique_images[@]}"
# docker_rmi "${new_images[@]}"