#!/bin/bash

# 取得執行腳本當前目錄
DIR="$(dirname $0)"

# 字體顏色
source ../${DIR}/modules/colors.sh

# 列出所有的 GCP 項目
projects=$(gcloud projects list --format="value(projectId)")

# 將項目 ID 儲存在一個陣列中
project_array=()
while IFS= read -r project; do
  project_array+=("$project")
done <<< "$projects"

# 顯示所有項目 ID 並讓用戶選擇
selected_project=$(printf "%s\n" "${project_array[@]}" | fzf --prompt="Select a project: ")

# 檢查用戶是否選擇了項目
if [ -n "$selected_project" ]; then
  echo "Switching to project: $selected_project"
  gcloud config set project "$selected_project"
  echo "Switched to project: $(gcloud config get-value project)"
else
  echo "No project selected. Exiting."
  exit 1
fi