current_gcp_project() {
  CURRENT_PROJECT=$(gcloud config get-value project)
  echo -e "${BLUE}Current GCP project: $CURRENT_PROJECT${NC}"
}

switch_gcp_project() {
  # 列出所有的 GCP 項目
  local PROJECTS=$(gcloud projects list --format="value(projectId)")

  # 將項目 ID 儲存在一個陣列中
  local PROJECT_ARRARY=()
  while IFS= read -r PROJECT; do
    PROJECT_ARRARY+=("$PROJECT")
  done <<< "$PROJECTS"

  # 顯示所有項目 ID 並讓用戶選擇
  local SELECT_PROJECT=$(printf "%s\n" "${PROJECT_ARRARY[@]}" | fzf --prompt="Select a GCP project: ")

  # 檢查用戶是否選擇了項目
  if [ -n "$SELECT_PROJECT" ]; then
    echo -e "${BLUE}Switching to project: $SELECT_PROJECT${NC}"
    gcloud config set project "$SELECT_PROJECT"
    echo -e "${GREEN}Switched to project: $(gcloud config get-value project)${NC}"
  else
    echo -e "${RED}No project selected. Exiting.${NC}"
    exit 1
  fi
}