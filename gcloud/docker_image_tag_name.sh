#!/bin/bash

# 將 gcp 上的 docker image pull 下來，使用 docker image tag 更名。再 push 到 google artifact registry。

source ../modules/default.sh

echo -e "${BLUE}設定 gcloud 存放區位置相關聯的 Artifact Registry 網域。${NC}"

read -p "請輸入 gcloud 存放區位置 (例如:asia-east1): " location

# 檢查 location 是否為空
if [ -z $location ]; then
  echo -e "${RED}location 不得為空。${NC}"
  exit 1
else
  gcloud auth configure-docker ${location}-docker.pkg.dev
  echo -e "${GREEN}gcloud 存放區位置相關聯的 Artifact Registry 網域設定完成。${NC}"
fi

read -p "請輸入 pull image: " docker_pull_image
read -p "請輸入 push image: " docker_push_image

# 檢查 docker_pull_image 是否為空
if [ -z $docker_pull_image ]; then
  echo -e "${RED}docker_pull_image 不得為空。${NC}"
  exit 1
fi
# 檢查 docker_push_image 是否為空
if [ -z $docker_push_image ]; then
  echo -e "${RED}docker_push_image 不得為空。${NC}"
  exit 1
fi

echo -e "${BLUE}請確認輸入資訊無誤。${NC}"
echo -e "${YELLOW}pull image: ${docker_pull_image}${NC}"
echo -e "${YELLOW}push image: ${docker_push_image}${NC}"

read -p "是否確認輸入資訊無誤？(y/n): " confirm

if [ $confirm == "y" ]; then
  echo -e "${GREEN}開始執行...${NC}"
  docker pull ${docker_pull_image}
  if [ $? -ne 0 ]; then
    echo -e "${RED}docker image pull 失敗。${NC}"
    exit 1
  fi
  docker tag ${docker_pull_image} ${docker_push_image}
  if [ $? -ne 0 ]; then
    echo -e "${RED}docker image tag 失敗。${NC}"
    exit 1
  fi
  echo -e "${GREEN}docker image tag 更名完成。${NC}"
  docker push ${docker_push_image}
  if [ $? -ne 0 ]; then
    echo -e "${RED}docker image push 失敗。${NC}"
    exit 1
  fi
  echo -e "${GREEN}docker image push 完成。${NC}"
  echo -e "${GREEN}執行完成。${NC}"
elif [ $confirm == "n" ]; then
  echo -e "${YELLOW}退出執行。${NC}"
  exit 1
else
  echo -e "${RED}輸入錯誤，請重新執行腳本。${NC}"
  exit 1
fi
