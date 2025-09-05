get_current_gcp_project() {
  CURRENT_PROJECT_ID=$(gcloud config get-value project)
  CURRENT_PROJECT_NAME=$(gcloud projects describe "$CURRENT_PROJECT_ID" --format="value(name)" 2>/dev/null)
  
  if [[ -n "$CURRENT_PROJECT_NAME" ]]; then
    echo -e "${BLUE}當前的 GCP 專案: $CURRENT_PROJECT_ID ($CURRENT_PROJECT_NAME)${NC}"
    echo ""
  else
    echo -e "${BLUE}當前的 GCP 專案: $CURRENT_PROJECT_ID${NC}"
    echo ""
  fi
}

switch_gcp_project() {
  local PROJECTS=$(gcloud projects list --format="value(PROJECT_ID, NAME)")
  local PROJECT_IDS=()
  local PROJECT_NAMES=()
  local DISPLAY_OPTIONS=()

  # 使用兩個平行陣列來模擬 Map 功能
  while IFS=$'\t' read -r PROJECT_ID PROJECT_NAME; do
    if [[ -n "$PROJECT_ID" ]]; then
      PROJECT_IDS+=("$PROJECT_ID")
      PROJECT_NAMES+=("$PROJECT_NAME")
      # 建立顯示選項: "PROJECT_ID (PROJECT_NAME)"
      DISPLAY_OPTIONS+=("$PROJECT_ID ($PROJECT_NAME)")
    fi
  done <<< "$PROJECTS"

  # 使用 fzf 選擇專案
  local SELECTED_DISPLAY=$(printf "%s\n" "${DISPLAY_OPTIONS[@]}" | fzf --prompt="Select a GCP project: ")

  if [ -n "$SELECTED_DISPLAY" ]; then
    # 從選擇的顯示文字中提取 PROJECT_ID (在括號前的部分)
    local SELECTED_PROJECT_ID=$(echo "$SELECTED_DISPLAY" | sed 's/ (.*//')
    
    # 找到對應的專案名稱
    local PROJECT_NAME=""
    for i in "${!PROJECT_IDS[@]}"; do
      if [[ "${PROJECT_IDS[$i]}" == "$SELECTED_PROJECT_ID" ]]; then
        PROJECT_NAME="${PROJECT_NAMES[$i]}"
        break
      fi
    done
    
    gcloud config set project "$SELECTED_PROJECT_ID" > /dev/null 2>&1
    echo -e "${GREEN}Switched to project: $SELECTED_PROJECT_ID ($PROJECT_NAME)${NC}"
    echo ""
  else
    echo -e "${RED}No project selected. Exiting.${NC}"
    echo ""
    exit 1
  fi
}

ask_switch_gcp_project_interface() {
  get_current_gcp_project

  read -p "你想要切換 GCP 專案嗎? (y/n): " SWITCH_PROJECT
  if [[ "$SWITCH_PROJECT" =~ ^[Yy]$ ]]; then
    switch_gcp_project
  else
    echo -e "${YELLOW}跳過切換。${NC}"
    echo ""
  fi

  get_current_gcp_project
}