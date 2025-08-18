get_current_gcp_project() {
  CURRENT_PROJECT=$(gcloud config get-value project)
  echo -e "${BLUE}當前的 GCP 專案: $CURRENT_PROJECT${NC}"
}

switch_gcp_project() {
  local PROJECTS=$(gcloud projects list --format="value(projectId)")
  local PROJECT_ARRARY=()

  while IFS= read -r PROJECT; do
    PROJECT_ARRARY+=("$PROJECT")
  done <<< "$PROJECTS"

  local SELECT_PROJECT=$(printf "%s\n" "${PROJECT_ARRARY[@]}" | fzf --prompt="Select a GCP project: ")

  if [ -n "$SELECT_PROJECT" ]; then
    gcloud config set project "$SELECT_PROJECT" > /dev/null 2>&1
    echo -e "${GREEN}Switched to project: $(gcloud config get-value project)${NC}"
  else
    echo -e "${RED}No project selected. Exiting.${NC}"
    exit 1
  fi
}

switch_gcp_project_interface() {
  get_current_gcp_project

  read -p "你想要切換 GCP 專案嗎? (y/n): " SWITCH_PROJECT
  if [[ "$SWITCH_PROJECT" =~ ^[Yy]$ ]]; then
    switch_gcp_project
  else
    echo -e "${YELLOW}跳過切換。${NC}"
  fi

  get_current_gcp_project
}