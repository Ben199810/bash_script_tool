#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

function main() {
  ask_switch_context_and_namespace_interface
  ask_query_all_namespaces
  NAMESPACE_OPTION=$(get_namespace_option)
  find_loadbalancer_services
}

main