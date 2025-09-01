#!/bin/bash
source ../modules/default.sh
source ../modules/switch_gcp_project_enabled.sh

# 檢查 google container registry 用量
gcloud container images list-gcr-usage --project=$current_project