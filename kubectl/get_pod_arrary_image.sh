#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

services=(
  # "wolf"
  # "snoopy"
  # "screws"
  "screwdriver"
)

for service in "${services[@]}"; do
  echo "Service: $service"
  kubectl get pods -n interface -o yaml | grep "$service" | grep "asia-east1-docker.pkg.dev" | grep -v "prod-fa858d71" | grep -v imageID
done