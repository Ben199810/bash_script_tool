#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

# 檢查所有 resources 內所有的 container 使用的 image 名稱
OPTIONS=("deployment" "statefulset" "daemonset" "cronjob" "exit")
PS3="選擇 Kubernetes Resource: "
# all namespace resources
read -p "check all namespace resources? (y/n): " check_all_namespace
select OPT in "${OPTIONS[@]}"; do
  case $OPT in
    "deployment")
      echo -e "${BLUE}You chose to check Deployment.${NC}"
      OPTION=${OPT}
      ;;
    "statefulset")
      echo -e "${BLUE}You chose to check StatefulSet.${NC}"
      OPTION=${OPT}
      ;;
    "daemonset")
      echo -e "${BLUE}You chose to check DaemonSet.${NC}"
      OPTION=${OPT}
      ;;
    "cronjob")
      echo -e "${BLUE}You chose to check CronJob.${NC}"
      OPTION=${OPT}
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
  # 如果選擇了 all namespace，則使用 -A 參數
  if [[ "$check_all_namespace" == "y" ]]; then
    RESOURCES_AND_NAMESPACES=$(kubectl get $OPTION --context $CURRENT_CONTEXT -A -o jsonpath='{range .items[*]}{.metadata.name} {.metadata.namespace}{"\n"}{end}')
    RESOURCES=($(echo "$RESOURCES_AND_NAMESPACES" | awk '{print $1}'))
    NAMESPACES=($(echo "$RESOURCES_AND_NAMESPACES" | awk '{print $2}'))
  else 
    RESOURCES=$(kubectl get $OPTION --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.items[*].metadata.name}')
  fi
  break
done

# 遞迴取得所有 container 的 image 名稱
for i in "${!RESOURCES[@]}"; do
  if [[ "$check_all_namespace" == "y" ]]; then
    RESOURCE="${RESOURCES[$i]}"
    NAMESPACE="${NAMESPACES[$i]}"
    echo -e "${BLUE}Selected ${OPTION}: $RESOURCE in namespace: $NAMESPACE${NC}"
    # cronJob 需要使用 jsonpath 來取得 spec.jobTemplate.spec.template.spec.containers.image
    if [[ "$OPTION" == "cronJob" ]]; then
      CONTAINER_IMAGES=$(kubectl get ${OPTION} $RESOURCE --context $CURRENT_CONTEXT -n $NAMESPACE -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[*].image}')
    else
      CONTAINER_IMAGES=$(kubectl get ${OPTION} $RESOURCE --context $CURRENT_CONTEXT -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
    fi
  else
    RESOURCE="${RESOURCES[$i]}"
    echo -e "${BLUE}Selected ${OPTION}: $RESOURCE${NC}"
    # cronJob 需要使用 jsonpath 來取得 spec.jobTemplate.spec.template.spec.containers.image
    if [[ "$OPTION" == "cronJob" ]]; then
      CONTAINER_IMAGES=$(kubectl get ${OPTION} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.jobTemplate.spec.template.spec.containers[*].image}')
    else
      CONTAINER_IMAGES=$(kubectl get ${OPTION} $RESOURCE --context $CURRENT_CONTEXT -n $CURRENT_NAMESPACE -o jsonpath='{.spec.template.spec.containers[*].image}')
      echo -e "Images: $CONTAINER_IMAGES"
    fi
  fi
done