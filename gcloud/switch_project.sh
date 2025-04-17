#!/bin/bash
source ../modules/default.sh
source ../modules/gcloud_operate.sh

current_gcp_project

read -p "Do you want to switch GCP project? (y/n): " user_input
if [ "$user_input" == "y" ]; then
  switch_gcp_project
elif [ "$user_input" == "n" ]; then
  echo "Exiting."
else
  echo "Invalid input. Exiting."
  exit 1
fi

current_gcp_project