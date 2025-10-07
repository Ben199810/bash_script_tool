#!/bin/bash
# GCP IAM 管理模組
# 提供 Service Account 相關的查詢和管理功能
#
# 依賴：
#   - gcloud CLI
#   - fzf
#   - jq
#
# 全域變數：
#   - CURRENT_PROJECT_ID: 當前 GCP 專案 ID
#   - SELECTED_SERVICE_ACCOUNT: 選中的 Service Account（由 select_service_account 設定）

# 選擇 Service Account
# 設定全域變數 SELECTED_SERVICE_ACCOUNT
function select_service_account() {
  SELECTED_SERVICE_ACCOUNT=$(gcloud iam service-accounts list \
    --project="${CURRENT_PROJECT_ID}" \
    --format="value(email)" | \
    fzf --prompt="Choose Service Account: ")

  if [[ -z "${SELECTED_SERVICE_ACCOUNT}" ]]; then
    printf "%b%s%b\n" "${YELLOW}" "No Service Account selected, exiting script." "${NC}"
    exit 0
  fi
  printf "%b%s%b%s%b\n\n" "${GREEN}" "Selected Service Account: " "${YELLOW}" "${SELECTED_SERVICE_ACCOUNT}" "${NC}"
}

# 列出所有 Service Accounts
function list_service_accounts() {
  printf "%b%s%s%b\n" "${BLUE}" "Listing Service Accounts in project: " "${CURRENT_PROJECT_ID}" "${NC}"

  local service_accounts
  service_accounts=$(gcloud iam service-accounts list \
    --project="${CURRENT_PROJECT_ID}" \
    --format="value(email)" 2>/dev/null)

  if [[ -z "${service_accounts}" ]]; then
    printf "%b%s%s%b\n" "${YELLOW}" "No service accounts found in project: " "${CURRENT_PROJECT_ID}" "${NC}"
  else
    printf "%s\n" "${service_accounts}"
  fi
}

# 查詢 Service Account 的 IAM 角色
function query_service_account_roles() {
  select_service_account

  local iam_roles
  iam_roles=$(gcloud projects get-iam-policy "${CURRENT_PROJECT_ID}" \
    --flatten="bindings[].members" \
    --format="value(bindings.role)" \
    --filter="bindings.members:${SELECTED_SERVICE_ACCOUNT}" 2>/dev/null)

  if [[ -z "${iam_roles}" ]]; then
    printf "%b%s%b\n" "${YELLOW}" "該 Service Account 在專案層級中沒有任何 IAM 角色綁定" "${NC}"
  else
    printf "%b%s%b\n" "${BLUE}" "=== 該 Service Account 的 IAM 角色綁定 ===" "${NC}"
    printf "%s\n" "${iam_roles}"
  fi
  printf "%b%s%b\n" "${GREEN}" "✅ Service Account 角色綁定查詢完成！" "${NC}"
}

# 查詢 Service Account 的 Workload Identity 綁定
function query_service_account_workload_identity() {
  select_service_account

  printf "%b%s%b\n" "${BLUE}" "正在查詢 Service Account 的 Workload Identity 綁定..." "${NC}"
  
  local wi_result
  wi_result=$(gcloud iam service-accounts get-iam-policy "${SELECTED_SERVICE_ACCOUNT}" \
    --project="${CURRENT_PROJECT_ID}" \
    --format="json" 2>/dev/null)

  if [[ -z "${wi_result}" ]] || [[ "${wi_result}" == "{}" ]] || [[ "${wi_result}" == "null" ]]; then
    printf "%b%s%b\n" "${YELLOW}" "該 Service Account 沒有任何 Workload Identity 綁定" "${NC}"
  else
    printf "%b%s%b\n" "${BLUE}" "=== 該 Service Account 的 Workload Identity 綁定資訊 ===" "${NC}"
    
    local bindings
    bindings=$(printf "%s" "${wi_result}" | jq -r '.bindings[]? | "\(.role): \(.members | join(", "))"')

    if [[ -n "${bindings}" ]]; then
      printf "%b%s%b\n" "${GREEN}" "找到以下 Bindings：" "${NC}"
      printf "%s\n" "${bindings}" | while IFS=': ' read -r role members; do
        printf "%b%s%b%s%b\n" "${YELLOW}" "角色: " "${CYAN}" "${role}" "${NC}"
        printf "%b%s%b%s%b\n" "${YELLOW}" "成員: " "${CYAN}" "${members}" "${NC}"
      done
    else
      printf "%b%s%b\n" "${YELLOW}" "沒有找到任何 Bindings" "${NC}"
    fi
  fi

  printf "%b%s%b\n" "${GREEN}" "✅ Service Account Workload Identity 綁定查詢完成！" "${NC}"
}