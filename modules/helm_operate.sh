# jq 這是一個用於處理 JSON 的命令行工具
# -r 這個選項告訴 jq 輸出原始字符串，而不是 JSON 格式的字符串


helm_list(){
  helm list --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE -o json | jq -r '.[] | "\(.name) \(.chart) \(.status) \n"'
}

helm_list_all_namespace(){
  helm list --kube-context $CURRENT_CONTEXT --all-namespaces -o json | jq -r '.[] | "\(.name) \(.namespace) \(.chart) \(.status) \n"'
}

helm_get_manifest(){
  local RELEASE_NAME="$1"
  local RELEASE_NAMES=("$2")

  # 選擇RELEASE_NAME From RELEASE_NAMES
  if [ -z "$RELEASE_NAME" ]; then
    RELEASE_NAMES=($(helm list --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE -o json | jq -r '.[].name'))
    if [ ${#RELEASE_NAMES[@]} -eq 0 ]; then
      echo "No releases found in the current namespace."
      exit 1
    fi
    RELEASE_NAME=$(printf '%s\n' "${RELEASE_NAMES[@]}" | fzf)
  fi

  helm get manifest $RELEASE_NAME --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE
}