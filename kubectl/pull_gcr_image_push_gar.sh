#!/bin/bash
source ../kubectl/check_resource_image.sh
source ../modules/docker_operate.sh

gcr_images=()
new_gar_images=()

# images 陣列中過濾開頭為 gcr.io/rd6-project 的 image 名稱
if [[ ${#images[@]} -gt 0 ]]; then
  for i in "${!images[@]}"; do
    if [[ "${images[$i]}" == gcr.io/rd6-project/* ]]; then
      gcr_images+=("${images[$i]}")
    fi
  done
fi

# gcr_image 篩選重複的 image 名稱
if [ ${#gcr_images[@]} -gt 0 ]; then
  unique_gcr_images=($(printf "%s\n" "${gcr_images[@]}" | sort -u))
  echo -e "${BLUE}GCR images:${NC}"
  for image in "${unique_gcr_images[@]}"; do
    echo -e "${GREEN}$image${NC}"
    # gcr.io 字串替換 asia-east1-docker.pkg.dev/gcp-20210526-001
    new_gar_image=$(echo "$image" | sed 's/gcr.io/asia-east1-docker.pkg.dev\/gcp-20210526-001/g')
    new_gar_images+=("$new_gar_image")
  done
else
  echo -e "${RED}No GCR images found.${NC}"
  exit 1
fi

if [[ ${#new_gar_images[@]} -gt 0 ]]; then
  echo -e "${BLUE}New GAR images:${NC}"
  for image in "${new_gar_images[@]}"; do
    echo -e "${GREEN}$image${NC}"
  done
else
  echo -e "${RED}No new GAR images found.${NC}"
  exit 1
fi

# docker operations
docker_pull "${unique_gcr_images[@]}"
docker_tag unique_gcr_images[@] new_gar_images[@]
docker_push "${new_gar_images[@]}"
docker_rmi "${unique_gcr_images[@]}"
docker_rmi "${new_gar_images[@]}"