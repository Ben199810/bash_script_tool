#!/bin/bash
source ../modules/default.sh
source ../modules/docker_operate.sh

images=()
new_images=()

docker_pull "${images[@]}"
docker_tag images[@] new_images[@]
docker_push "${new_images[@]}"
docker_rmi "${images[@]}"
docker_rmi "${new_images[@]}"