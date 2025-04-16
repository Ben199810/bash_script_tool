#!/bin/bash
source ../modules/default.sh

# 對複數個 clusters 的 resources 進行檢查
plural_cluster=(
  gke_gcp-20221202-001_asia-southeast1-c_rd1-bbchat-prod
  gke_gcp-20221202-002_asia-southeast1-c_rd1-bbchat-qa
  gke_gcp-20221202-003_asia-southeast1-c_rd1-bbchat-dev
  gke_gcp-20240426-001_asia-southeast1-c_rd1-bbchat-staging
)

resource_types=(
  deployment
  statefulset
)

for cluster in "${plural_cluster[@]}"; do
  echo -e "${BLUE}Cluster: $cluster${NC}"
  for resource_type in "${resource_types[@]}"; do
    echo -e "${BLUE}Resource: $resource_type${NC}"
    RESOURCE_NAMES=($(kubectl get $resource_type --context $cluster -A -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'))
    NAMESPACES=($(kubectl get $resource_type --context $cluster -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"\n"}{end}'))

    if [ ${#RESOURCE_NAMES[@]} -eq 0 ]; then
      echo -e "${RED}No resources found for $resource_type in cluster $cluster${NC}"
    else
      for i in "${!RESOURCE_NAMES[@]}"; do
        # 取得資源名稱和命名空間
        resource_name=$(echo ${RESOURCE_NAMES[$i]})
        namespace=$(echo ${NAMESPACES[$i]})
        echo -e "${BLUE}Resource Name: $resource_name in Namespace: $namespace${NC}"
        # 取得 Container Name
        CONTAINER_NAMES=($(kubectl get $resource_type $resource_name --context $cluster -n $namespace -o jsonpath='{.spec.template.spec.containers[*].name}'))
        for container_name in "${CONTAINER_NAMES[@]}"; do
          if [ $container_name == "app" ]; then
            echo -e "${RED}Container Name: $container_name${NC}"
          else
            echo -e "${GREEN}Container Name: $container_name${NC}"
          fi
        done
      done
    fi
  done
done