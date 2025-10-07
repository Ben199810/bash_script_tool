# GCP 資源管理工具

> 統一的 GCP 雲端資源管理腳本，提供互動式介面操作 IAM、Network、IAP、Memorystore 等服務。

## 📁 專案結構

```text
cloud/gcp/
├── default.sh                      # 🎯 主入口腳本（互動式選單）
├── modules/                        # 📦 功能模組
│   ├── iam.sh                     # IAM 相關函數
│   ├── iap.sh                     # IAP 隧道相關函數
│   ├── memorystore.sh             # Memorystore 相關函數
│   ├── network.sh                 # 網路搜尋相關函數
│   └── switch_gcp_project.sh      # GCP 專案切換函數
└── README.md                       # 📖 本文件
```

### 🔄 架構說明

- **模組化設計**：所有功能函數都定義在 `modules/` 目錄下的模組文件中
- **統一入口**：`default.sh` 作為主入口，載入所有模組並提供互動式選單
- **無重複代碼**：所有模組共用函數，避免重複定義

## 🚀 快速開始

### 方法一：互動式選單（推薦）

執行主腳本，通過選單選擇操作：

```bash
cd /path/to/bash_script_tool/cloud/gcp
./default.sh
```

### 方法二：直接使用模組

在其他腳本中引用模組：

```bash
#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/default.sh"

# 使用模組函數
ask_switch_gcp_project_interface
list_service_accounts
```

## 📋 功能清單

### 🔐 IAM 管理

| 功能 | 函數名稱 | 說明 |
|-----|---------|-----|
| 列出 Service Accounts | `list_service_accounts` | 顯示當前專案的所有 Service Accounts |
| 查詢 SA 角色 | `query_service_account_roles` | 查詢指定 SA 的 IAM 角色綁定 |
| 查詢 Workload Identity | `query_service_account_workload_identity` | 查詢 SA 的 Workload Identity 綁定資訊 |

### 🌐 網路管理

| 功能 | 函數名稱 | 說明 |
|-----|---------|-----|
| 搜尋 IP 地址 | `find_ip_in_project` | 在專案中搜尋靜態 IP、實例 IP、轉發規則 |

**支援的資源類型：**

- ✅ 靜態 IP 地址（Compute Addresses）
- ✅ GCE 實例 IP（內部/外部）
- ✅ 轉發規則 IP（Forwarding Rules）

### 🔌 IAP 隧道連線

| 功能 | 函數名稱 | 說明 |
|-----|---------|-----|
| SSH 連線 | `start_iap_tunnel` | 透過 IAP 隧道 SSH 連線到 GCE 實例 |
| Port Forward | `use_iap_tunnel_port_forwarding_memorystore` | 透過跳板機 Port Forward 到 Memorystore |

### 💾 Memorystore 管理

| 功能 | 函數名稱 | 說明 |
|-----|---------|-----|
| 列出實例 | `list_memorystore_instances` | 列出指定區域或所有區域的 Memorystore 實例 |

### ⚙️ 專案管理

| 功能 | 函數名稱 | 說明 |
|-----|---------|-----|
| 切換專案 | `switch_gcp_project` | 切換當前使用的 GCP 專案 |
| 詢問切換 | `ask_switch_gcp_project_interface` | 啟動時詢問是否需要切換專案 |

## 📦 依賴項目

### 必要工具

| 工具 | 用途 | 安裝方式 |
|-----|------|---------|
| `gcloud` | GCP CLI 工具 | [安裝指南](https://cloud.google.com/sdk/docs/install) |
| `fzf` | 模糊搜尋工具 | `brew install fzf` |
| `jq` | JSON 處理工具 | `brew install jq` |

### 共用模組

- `../../modules/default.sh` - 基礎函數和顏色定義

## 💡 使用範例

### 範例 1：查詢 Service Account 角色

```bash
#!/bin/bash
source "cloud/gcp/default.sh"

# 自動詢問是否切換專案
ask_switch_gcp_project_interface

# 查詢 Service Account 角色
query_service_account_roles
```

### 範例 2：搜尋 IP 地址

```bash
#!/bin/bash
source "cloud/gcp/default.sh"

# 搜尋特定 IP
find_ip_in_project
# 輸入: 10.128.0.5
# 輸出: 顯示該 IP 相關的所有 GCP 資源
```

### 範例 3：透過 IAP 連線到 Memorystore

```bash
#!/bin/bash
source "cloud/gcp/default.sh"

# 選擇跳板機和 Memorystore 實例
use_iap_tunnel_port_forwarding_memorystore
# 本地 localhost:6379 -> Memorystore
```

## 🔧 開發指南

### 新增功能模組

1. 在 `modules/` 目錄下創建新模組文件：

   ```bash
   touch cloud/gcp/modules/your_module.sh
   ```

2. 在 `default.sh` 中引用模組：

   ```bash
   source "modules/your_module.sh"
   ```

3. 在主選單中添加新功能：

   ```bash
   local MAIN_OPERATIONS=(
     # ... 其他選項
     "Your Feature - Description"
   )
   ```

### 編碼規範

根據 `AGENTS.md` 規範：

- ✅ 使用 2 個空格縮排
- ✅ 全域變數：大寫+底線（如 `CURRENT_PROJECT_ID`）
- ✅ 私有變數：小寫+底線（如 `service_accounts`）
- ✅ 函數名稱：動詞開頭（如 `list_`, `query_`, `get_`）
- ✅ 使用 `function` 關鍵字宣告函式
- ✅ 使用 `[[ ... ]]` 進行條件測試
- ✅ 使用 `local` 宣告區域變數

## 🐛 故障排除

### 常見問題

#### Q: 執行時提示 "command not found: fzf"

```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt-get install fzf
```

#### Q: gcloud 認證錯誤

```bash
# 重新登入
gcloud auth login

# 設定預設專案
gcloud config set project YOUR_PROJECT_ID
```

#### Q: 無法讀取模組文件

```bash
# 確保在正確的目錄執行
cd /path/to/bash_script_tool/cloud/gcp
./default.sh
```

## 📝 更新日誌

### 2025-10-07

- ✨ 重構為模組化架構
- 🔧 將所有功能函數移至 `modules/` 目錄
- 📝 統一命名規範（符合 AGENTS.md）
- 🐛 修正函數重複定義問題
- ✅ 新增完整的註解和錯誤處理

### 2025-10-03

- 🎉 初始版本
- ✨ 整合 IAM、Network、IAP、Memorystore 功能

## 👤 維護資訊

- **維護者**: Ben199810
- **專案**: bash_script_tool
- **分支**: main
- **最後更新**: 2025-10-07

## 📄 授權

此專案為內部工具，請遵守公司相關規範使用。

---

💡 **提示**: 建議首次使用者執行 `./default.sh` 體驗互動式選單，熟悉後可直接在腳本中引用模組函數。
