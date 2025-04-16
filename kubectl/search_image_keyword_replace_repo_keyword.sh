#!/bin/bash
source ../kubectl/check_resource_image.sh
source ../modules/docker_operate.sh

gcr_images=()
repo_path=(
  /Users/bing-wei/Documents/swissknife/SRE/pid-cluster-yaml/bbgp/outside
  /Users/bing-wei/Documents/swissknife/SRE/pid-cluster-yaml/bbin/outside
  /Users/bing-wei/Documents/swissknife/SRE/images-build/PI
  /Users/bing-wei/Documents/swissknife/SRE/images-build/base
  /Users/bing-wei/Documents/swissknife/SRE/images-build/inf
  /Users/bing-wei/Documents/swissknife/SRE/images-build/proxy-server
  /Users/bing-wei/Documents/swissknife/SRE/images-build/cicd
)
# read -p "請輸入要搜尋的 image 關鍵字: " keyword
keyword="gcr.io/rd6-project"

# images 陣列中過濾開頭為 gcr.io/rd6-project 的 image 名稱
if [[ ${#images[@]} -gt 0 ]]; then
  for i in "${!images[@]}"; do
    if [[ "${images[$i]}" == ${keyword}* ]]; then
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
  done
else
  echo -e "${RED}No GCR images found.${NC}"
  exit 1
fi

# GCR images 以 ":" 分割，取 image 名稱
if [[ ${#unique_gcr_images[@]} -gt 0 ]]; then
  gcr_image_names=()
  echo -e "${BLUE}GCR image names:${NC}"
  for image in "${unique_gcr_images[@]}"; do
    # 取出 image 名稱
    image_name=$(echo "$image" | cut -d ':' -f 1)
    echo -e "${GREEN}$image_name${NC}"
    gcr_image_names+=("$image_name")
  done
fi

# 遞回搜尋 repo_path 中的所有檔案(.yaml 或 .yml)
for path in "${repo_path[@]}"; do
  find "$path" -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
    # 檢查檔案中是否包含 gcr_image_names 的 image 名稱
    for image_name in "${gcr_image_names[@]}"; do
      if grep -q "$image_name" "$file"; then
        # 列印出檔案名稱和行號
        echo -e "${BLUE}檔案: $file${NC}"
        echo -e "${GREEN}行號: $(grep -n "$image_name" "$file" | cut -d ':' -f 1)${NC}"
        # 列印出檔案內容
        echo -e "${GREEN}內容: $(grep "$image_name" "$file")${NC}"
      fi
    done
  done
done