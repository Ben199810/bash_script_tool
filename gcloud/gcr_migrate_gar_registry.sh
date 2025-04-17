#!/bin/bash
source ../gcloud/switch_project.sh

gcloud artifacts docker upgrade migrate --projects=$CURRENT_PROJECT