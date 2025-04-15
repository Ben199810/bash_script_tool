docker_pull() {
  local images=("$@")
  for image in "${images[@]}"; do
    echo -e "${BLUE}Pulling image: $image${NC}"
    docker pull $image
  done
}

docker_tag() {
  local -a images=("${!1}")      # 第一個陣列參數
  local -a new_images=("${!2}")  # 第二個陣列參數

  if [[ ${#images[@]} -ne ${#new_images[@]} ]]; then
    echo -e "${RED}Error: The number of images and new images must match.${NC}"
    exit 1
  fi

  for i in "${!images[@]}"; do
    local image="${images[$i]}"
    local new_image="${new_images[$i]}"
    echo -e "${BLUE}Tagging image: $image -> $new_image${NC}"
    docker tag "$image" "$new_image"
  done
}

docker_push() {
  local images=("$@")
  for image in "${images[@]}"; do
    echo -e "${BLUE}Pushing image: $image${NC}"
    docker push $image
  done
}

docker_rmi() {
  local images=("$@")
  for image in "${images[@]}"; do
    echo -e "${BLUE}Removing image: $image${NC}"
    docker rmi $image
  done
}