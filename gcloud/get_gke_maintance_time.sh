#!/bin/bash
source ../modules/default.sh

PROJECTS=$(gcloud projects list --format="value(projectId)")

for PROJECT in $PROJECTS; do
  GKES=$(gcloud container clusters list --project "$PROJECT" --format="value(name,location)" 2>/dev/null)
  if [[ -n "$GKES" ]]; then
    while IFS=$'\t' read -r CLUSTER_NAME LOCATION; do
      if [[ -n "$CLUSTER_NAME" && -n "$LOCATION" ]]; then
        echo -e "${BLUE}專案 ID: $PROJECT, Cluster 名稱: $CLUSTER_NAME, Location: $LOCATION${NC}"
        RECURRENCE=$(gcloud container clusters describe "$CLUSTER_NAME" \
          --location="$LOCATION" \
          --project="$PROJECT" \
          --format="value(maintenancePolicy.window.recurringWindow.recurrence)")
        START_TIME=$(gcloud container clusters describe "$CLUSTER_NAME" \
          --location="$LOCATION" \
          --project="$PROJECT" \
          --format="value(maintenancePolicy.window.recurringWindow.window.startTime)")
        END_TIME=$(gcloud container clusters describe "$CLUSTER_NAME" \
          --location="$LOCATION" \
          --project="$PROJECT" \
          --format="value(maintenancePolicy.window.recurringWindow.window.endTime)")
        if [[ -n "$RECURRENCE" ]] && [[ -n "$START_TIME" ]]; then
          echo -e "${GREEN}維護排程: $RECURRENCE, 開始時間: $START_TIME, 結束時間: $END_TIME${NC}"
          # 如果 cluster name 有 prod 關鍵字
          if [[ "$CLUSTER_NAME" == *"prod"* ]]; then
            if [[ $RECURRENCE == "FREQ=WEEKLY;BYDAY=MO,TU,TH" ]] && [[ $START_TIME == "2023-01-01T01:00:00Z" ]] && [[ $END_TIME == "2023-01-01T06:00:00Z" ]]; then
              echo -e "${GREEN}與預設維護排程相符${NC}"
              echo ""
            else
              echo -e "${YELLOW}與預設維護排程不符，請檢查${NC}"
              echo ""
            fi
          else
            if [[ $RECURRENCE == "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU" ]] && [[ $START_TIME == "2023-01-01T14:00:00Z" ]] && [[ $END_TIME == "2023-01-01T21:00:00Z" ]]; then
              echo -e "${GREEN}與預設維護排程相符${NC}"
              echo ""
            else
              echo -e "${YELLOW}與預設維護排程不符，請檢查${NC}"
              echo ""
            fi
          fi
        else
          echo -e "${YELLOW}沒有設定維護排程${NC}"
          echo ""
        fi
      fi
    done <<< "$GKES"
  else
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}無權限訪問此專案的 GKE 叢集: $PROJECT${NC}"
      echo ""
    else
      echo -e "${RED}此專案沒有 GKE 叢集: $PROJECT${NC}"
      echo ""
    fi
  fi
done
