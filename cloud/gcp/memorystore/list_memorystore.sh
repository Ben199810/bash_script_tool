#!/bin/bash
DIR="$(dirname $0)"
source "$DIR/../../../modules/default.sh"
source "$DIR/../../../modules/switch_gcp_project.sh"
source "$DIR/../../../modules/memorystore.sh"  # 新增：引入 Memorystore 模組

switch_gcp_project_interface

# 主要功能函數
list_memorystore_interface() {
    local OPERATION_ARRAY=(
        "列出指定區域的 Memorystore 實例"
        "列出所有區域的 Memorystore 實例"
    )
    
    local OPERATION=$(printf "%s\n" "${OPERATION_ARRAY[@]}" | fzf --header="選擇操作:" --prompt="操作: ")
    
    case $OPERATION in
        "列出指定區域的 Memorystore 實例")
            get_memorystore_instances
            if [ ! -z "$MEMORYSTORE_INSTANCES" ]; then
                echo -e "${GREEN}Memorystore 實例列表:${NC}"
                echo -e "實例名稱\t區域\t主機\t端口\t狀態"
                echo -e "----------------------------------------"
                echo -e "$MEMORYSTORE_INSTANCES"
            else
                echo -e "${YELLOW}在區域 $MEMORYSTORE_REGION 中沒有找到 Memorystore 實例。${NC}"
            fi
            ;;
        "列出所有區域的 Memorystore 實例")
            get_all_memorystore_instances
            if [ ! -z "$MEMORYSTORE_INSTANCES" ]; then
                echo -e "${GREEN}所有區域的 Memorystore 實例列表:${NC}"
                echo -e "實例名稱\t區域\t主機\t端口\t狀態"
                echo -e "----------------------------------------"
                echo -e "$MEMORYSTORE_INSTANCES"
            else
                echo -e "${YELLOW}沒有找到任何 Memorystore 實例。${NC}"
            fi
            ;;
    esac
}

# 執行主要功能
list_memorystore_interface