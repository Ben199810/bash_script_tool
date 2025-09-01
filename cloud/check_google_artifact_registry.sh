#!/bin/bash
source ../gcloud/switch_project.sh

# 顯示所有的 Artifact Registry
# gcloud artifacts repositories list

# 查看特定的 Artifact Registry
read -p "Enter the name of the Artifact Registry you want to check: " REPO_NAME
read -p "Enter the location of the Artifact Registry (e.g., us-central1): " LOCATION

if [ -z "$REPO_NAME" ] || [ -z "$LOCATION" ]; then
  REPO_NAME="pd"
  LOCATION="asia-east1"
fi
# 詳細資訊
# gcloud artifacts repositories describe $REPO_NAME --location=$LOCATION
# 列出所有的 packages
# gcloud artifacts packages list --repository=$REPO_NAME --location=$LOCATION

PACKAGES_TEMP=$(gcloud artifacts packages list --repository=$REPO_NAME --location=$LOCATION --format="value(name)")

PACKAGES=()
for PACKAGE in $PACKAGES_TEMP; do
  PACKAGES+=("$PACKAGE")
done

# fzf
PACKAGE=$(printf '%s\n' "${PACKAGES[@]}" | fzf)

# echo "Packages: $PACKAGES"

echo "Selected package: $PACKAGE"

# gcloud artifacts versions list --repository=$REPO_NAME --location=$LOCATION --package=$PACKAGE

# echo "gcloud artifacts docker tags list $LOCATION-docker.pkg.dev/$CURRENT_PROJECT/$REPO_NAME/$PACKAGE"

gcloud artifacts docker tags list $LOCATION-docker.pkg.dev/$CURRENT_PROJECT/$REPO_NAME/$PACKAGE