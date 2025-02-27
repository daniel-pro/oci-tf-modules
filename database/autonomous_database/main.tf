resource "oci_database_autonomous_database" "autonomous_database" {
  for_each = var.autonomous_dbs
    #Required
    compartment_id = each.value.compartment_id
    admin_password = each.value.admin_password

    #Optional
    are_primary_whitelisted_ips_used = lookup(each.value, "are_primary_whitelisted_ips_used", null)
    auto_refresh_frequency_in_seconds = lookup(each.value, "auto_refresh_frequency_in_seconds", null)
    auto_refresh_point_lag_in_seconds = lookup(each.value, "auto_refresh_point_lag_in_seconds", null)
    autonomous_container_database_id = lookup(each.value, "autonomous_container_database_id", null)
    autonomous_database_backup_id = lookup(each.value, "autonomous_database_backup_id", null)
    autonomous_database_id = lookup(each.value, "autonomous_database_id", null)
    autonomous_maintenance_schedule_type = lookup(each.value, "autonomous_maintenance_schedule_type", null)
    backup_retention_period_in_days = lookup(each.value, "backup_retention_period_in_days", null)
    character_set = lookup(each.value, "character_set", null)
    # clone_table_space_list = lookup(each.value, "clone_table_space_list", null)
    clone_type = lookup(each.value, "clone_type", null)
    compute_count = lookup(each.value, "compute_count", null)
    compute_model = lookup(each.value, "compute_model", null)
    cpu_core_count = lookup(each.value, "cpu_core_count", null)
    dynamic customer_contacts {
        for_each = lookup(each.value, "customer_contacts", {})
        content {
            #Optional
            email = lookup(customer_contacts.value, "email", null)
        }
    }
    data_safe_status = lookup(each.value, "data_safe_status", null)
    data_storage_size_in_gb = lookup(each.value, "data_storage_size_in_gb", null)
    data_storage_size_in_tbs = lookup(each.value, "data_storage_size_in_tbs", null)
    database_edition = lookup(each.value, "database_edition", null)
    db_name =  lookup(each.value, "db_name", each.key)
    dynamic db_tools_details {
        for_each = lookup(each.value, "db_tools_details", {})
        content {
            #Required
            name = lookup(db_tools_details.value, "name", null)

            #Optional
            compute_count = lookup(eadb_tools_detailsch.value, "compute_count", null)
            is_enabled = lookup(db_tools_details.value, "is_enabled", null)
            max_idle_time_in_minutes = lookup(db_tools_details.value, "max_idle_time_in_minutes", null)
        }
    }
    db_version = lookup(each.value, "db_version", null)
    db_workload = lookup(each.value, "db_workload", null) # OLTP DW APEX AJD
    defined_tags = lookup(each.value, "defined_tags", null)
    disaster_recovery_type = lookup(each.value, "disaster_recovery_type", null)
    display_name = lookup(each.value, "display_name", each.key)
    dynamic encryption_key {
        for_each = lookup(each.value, "encryption_key", {})
        content {
            #Optional
            arn_role = lookup(each.encryption_key, "arn_role", null)
            autonomous_database_provider = lookup(each.encryption_key, "autonomous_database_provider", null)
            certificate_directory_name = lookup(each.encryption_key, "certificate_directory_name", null)
            certificate_id = lookup(each.encryption_key, "certificate_id", null)
            directory_name = lookup(each.encryption_key, "directory_name", null)
            external_id = lookup(each.encryption_key, "external_id", null)
            key_arn = lookup(each.encryption_key, "key_arn", null)
            key_name = oci_kms_key.test_key.name
            kms_key_id = oci_kms_key.test_key.id
            okv_kms_key = lookup(each.encryption_key, "okv_kms_key", null)
            okv_uri = lookup(each.encryption_key, "okv_uri", null)
            service_endpoint_uri = lookup(each.encryption_key, "service_endpoint_uri", null)
            vault_id = oci_kms_vault.test_vault.id
            vault_uri = lookup(each.encryption_key, "vault_uri", null)
        }
    }
    freeform_tags = lookup(each.value, "freeform_tags", null)
    in_memory_percentage = lookup(each.value, "in_memory_percentage", null)
    is_access_control_enabled = lookup(each.value, "is_access_control_enabled", null)
    is_auto_scaling_enabled = lookup(each.value, "is_auto_scaling_enabled", null)
    is_auto_scaling_for_storage_enabled = lookup(each.value, "is_auto_scaling_for_storage_enabled", null)
    # is_backup_retention_locked = lookup(each.value, "is_backup_retention_locked", null)
    is_data_guard_enabled = lookup(each.value, "is_data_guard_enabled", null)
    is_dedicated = lookup(each.value, "is_dedicated", null)
    is_dev_tier = lookup(each.value, "is_dev_tier", null)
    is_free_tier = lookup(each.value, "is_free_tier", null)
    is_local_data_guard_enabled = lookup(each.value, "is_local_data_guard_enabled", null)
    is_mtls_connection_required = lookup(each.value, "is_mtls_connection_required", null)
    is_preview_version_with_service_terms_accepted = lookup(each.value, "is_preview_version_with_service_terms_accepted", null)
    is_replicate_automatic_backups = lookup(each.value, "is_replicate_automatic_backups", null)
    kms_key_id = lookup(each.value, "kms_key_id", null)
    license_model = lookup(each.value, "license_model", null)
    max_cpu_core_count = lookup(each.value, "max_cpu_core_count", null)
    ncharacter_set = lookup(each.value, "ncharacter_set", null)
    nsg_ids = lookup(each.value, "nsg_ids", null)
    ocpu_count = lookup(each.value, "ocpu_count", null)
    private_endpoint_label = lookup(each.value, "private_endpoint_label", null)
    refreshable_mode = lookup(each.value, "refreshable_mode", null)
    resource_pool_leader_id = lookup(each.value, "resource_pool_leader_id", null)
    dynamic resource_pool_summary {
        for_each = lookup(each.value, "resource_pool_summary", {})
        content {        
            #Optional
            is_disabled = lookup(resource_pool_summary.value, "is_disabled", null)
            pool_size = lookup(resource_pool_summary.value, "pool_size", null)
        }
    }
    dynamic scheduled_operations {
        for_each = lookup(each.value, "scheduled_operations", {})
        content {        
            #Required
            day_of_week {
                #Required
                name = lookup(scheduled_operations.value, "day_of_week_name", null)
            }
            #Optional
            scheduled_start_time = lookup(scheduled_operations.value, "scheduled_start_time", null)
            scheduled_stop_time = lookup(scheduled_operations.value, "scheduled_stop_time", null)
        }
    }
    secret_id = lookup(each.value, "secret_id", null)
    secret_version_number = lookup(each.value, "secret_version_number", null)
    security_attributes = lookup(each.value, "security_attributes", null)
    source = lookup(each.value, "source", null)
    source_id = lookup(each.value, "source_id", null)
    standby_whitelisted_ips = lookup(each.value, "standby_whitelisted_ips", null)
    subnet_id = lookup(each.value, "subnet_id", null)
    subscription_id = lookup(each.value, "subscription_id", null)
    time_of_auto_refresh_start = lookup(each.value, "time_of_auto_refresh_start", null)
    timestamp = lookup(each.value, "timestamp", null)
    use_latest_available_backup_time_stamp = lookup(each.value, "use_latest_available_backup_time_stamp", null)
    vault_id = lookup(each.value, "vault_id", null)
    whitelisted_ips = lookup(each.value, "whitelisted_ips", null)
}