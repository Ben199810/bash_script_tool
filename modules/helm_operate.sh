helm_list(){
  helm list --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE
}

helm_list_all_namespace(){
  helm list --kube-context $CURRENT_CONTEXT --all-namespaces
}

helm_get_manifest(){
  RELEASE_NAME=$1
  helm get manifest $RELEASE_NAME --kube-context $CURRENT_CONTEXT --namespace $CURRENT_NAMESPACE
}