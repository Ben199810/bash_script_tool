docker_pull() {
  local image="$1"
  echo -e "${BLUE}Pulling image: $image${NC}"
  docker pull "$image"
}

docker_tag() {
  local image="$1"
  local new_image="$2"
  if [ "$image" != "" ] && [ "$new_image" != "" ]; then
    echo -e "${YELLOW}Tagging image: $image -> $new_image${NC}"
    docker tag "$image" "$new_image"
  elif [ "$image" == "" ] || [ "$new_image" == "" ]; then
    echo -e "${RED}Error: image and new_image must be provided.${NC}"
    if [ -z "$image" ]; then
      echo -e "${RED}Error: image is not set.${NC}"
    fi
    if [ -z "$new_image" ]; then
      echo -e "${RED}Error: new_image is not set.${NC}"
    fi
  fi
}

docker_push() {
  local image="$1"
  echo -e "${BLUE}Pushing image: $image${NC}"
  docker push "$image"
}

docker_rmi() {
  local image="$1"
  echo -e "${BLUE}Removing image: $image${NC}"
  docker rmi "$image"
}