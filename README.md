# bash_script_tool

收錄 aws, gcloud, kubectl 等腳本功能工具，方便使用 bash 腳本進行雲端資源的管理和操作。

## 目錄

```shell
.
├── README.md
├── aws
│   ├── sso_login.sh
│   ├── sso_login_and_switch_profile.sh
│   └── switch_profile.sh
├── common
│   └── macbook_default_install.sh
├── curl_test
│   └── curl_domain.sh
├── docker
│   └── push_latest_tag.sh
├── gcloud
│   ├── check_google_artifact_registry.sh
│   ├── check_google_container_registry_use.sh
│   ├── docker_image_tag_name.sh
│   ├── find_ip.sh
│   ├── gcr_migrate_gar_registry.sh
│   ├── gcs_buckets_notification_check.sh
│   ├── get_all_service-account_role.sh
│   ├── get_cloud_armor.sh
│   ├── iam_policy.sh
│   ├── list_unused_static_ips.sh
│   ├── service-account_permissions.sh
│   └── switch_project.sh
├── helm
│   ├── get_release_manifest.sh
│   ├── get_release_values.sh
│   └── show_release.sh
├── kafka
│   ├── delete_all_topic.sh
│   └── reset_kafka_topics.sh
├── kubectl
│   ├── check_hpa_apiversion.sh
│   ├── check_phpfpm_exporter_setting_with_datadog.sh
│   ├── check_plural_cluster_resources_all_container_name.sh
│   ├── check_resource_image.sh
│   ├── delete_fail_pending_job.sh
│   ├── delete_pending_status_pods.sh
│   ├── describe_pdb.sh
│   ├── get_backendConfig.sh
│   ├── get_plural_cluster_pdb.sh
│   ├── get_pod_arrary_image.sh
│   ├── get_pod_status.sh
│   ├── get_pv_driver.sh
│   ├── get_service.sh
│   ├── helm_take_over.sh
│   ├── pull_gcr_image_push_gar.sh
│   ├── rename_kubecontext.sh
│   ├── search_image_keyword_found_in_repo.sh
│   ├── select_deployment_check_container.sh
│   ├── simulate_node_upgrade.sh
│   └── switch_kubernetes_context.sh
├── modules
│   ├── check_install.sh
│   ├── default.sh
│   ├── docker_operate.sh
│   ├── gcloud_operate.sh
│   ├── helm_operate.sh
│   ├── kafka_vm_setting.sh
│   └── kubectl_operate.sh
├── stress_testing
│   └── ab_stress.sh
└── terragrunt
    └── repeat_apply_iam_user.sh
```
