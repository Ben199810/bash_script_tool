current_gcp_project() {
  CURRENT_PROJECT=$(gcloud config get-value project)
  echo -e "${BLUE}Current GCP project: $CURRENT_PROJECT${NC}"
}

switch_gcp_project() {
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
    echo -e "${BLUE}Switching to project: $selected_project${NC}"
    gcloud config set project "$selected_project"
    echo -e "${GREEN}Switched to project: $(gcloud config get-value project)${NC}"
  else
    echo -e "${RED}No project selected. Exiting.${NC}"
    exit 1
  fi
}