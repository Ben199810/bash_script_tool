# start_iap_tunnel

```mermaid
---
title: start_iap_tunnel
---
sequenceDiagram
    participant User
    participant Script
    participant GCloud
    participant SSH
    participant Memorystore

    User->>Script: 啟動腳本
    Script->>Script: switch_gcp_project_interface
    Script->>Script: get_running_gce_instances
    Script->>User: fzf 選擇 GCE
    User->>Script: 選擇 GCE
    Script->>Script: select_gce_instance
    Script->>Script: ask_user_and_connect
    alt 連線到 GCE
        Script->>Script: start_iap_tunnel
        Script->>GCloud: gcloud compute ssh --tunnel-through-iap
        GCloud->>GCE: 建立 IAP SSH
        GCE->>User: SSH 連線
    else port-forward Memorystore
        Script->>Script: use_iap_tunnel_port_forwarding_memorystore
        Script->>GCloud: gcloud compute start-iap-tunnel
        GCloud->>GCE: 建立 IAP 隧道
        Script->>SSH: ssh -L port-forward
        SSH->>Memorystore: 連線 Redis
        Memorystore-->>User: 服務可用
    end
````
