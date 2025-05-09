#!/bin/bash
source ../kubectl/switch_kubernetes_context.sh

RESORCETYPES_AND_RESOURCENAMES=(
  "secrets letsencrypt-account-key"
  "secrets wildcard-tls-rdapp-vip"
  "certificate wildcard-tls-rdapp-vip"
  "clusterissuers selfsigned"
)

RELEASE_NAME="cert-manager-letsencrypt"
NAMESPACE="cert-manager"

for RESOURETYPE_AND_RESOURCENAME in "${RESORCETYPES_AND_RESOURCENAMES[@]}"; do
  IFS=' ' read -r RESOURCETYPE RESOURCENAME <<< "$RESOURETYPE_AND_RESOURCENAME"
  kubectl label --overwrite $RESOURCETYPE $RESOURCENAME app.kubernetes.io/managed-by=Helm
  kubectl annotate --overwrite $RESOURCETYPE $RESOURCENAME meta.helm.sh/release-name=${RELEASE_NAME}
  kubectl annotate --overwrite $RESOURCETYPE $RESOURCENAME meta.helm.sh/release-namespace=${NAMESPACE}
done
