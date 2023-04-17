resource "oci_database_db_system" "db_system" {
  for_each = var.db_systems
    #Required
    availability_domain = each.value.availability_domain
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

    hostname = lookup(each.value, "hostname", each.key)
    shape = each.value.shape
    ssh_public_keys = each.value.ssh_public_keys
    subnet_id = each.value.subnet_id

    db_home {
        #Required
        database {
            #Required
            admin_password = each.value.db_home.database.admin_password

            #Optional
            backup_id = lookup(each.value.db_home.database, "backup_id", null)
            backup_tde_password = lookup(each.value.db_home.database, "backup_tde_password", null)
            character_set = lookup(each.value.db_home.database, "character_set", null)
            database_id = lookup(each.value.db_home.database, "database_id", null)
            database_software_image_id = lookup(each.value.db_home.database, "software_image_id", null)
            dynamic "db_backup_config" {
                for_each = { for key, value in each.value.db_home.database : key => value if key == "db_backup_config" }
                content {
                    #Optional
                    auto_backup_enabled = lookup(db_backup_config.value, "auto_backup_enabled", null)
                    auto_backup_window  = lookup(db_backup_config.value, "auto_backup_window", null)

                    dynamic "backup_destination_details" {
                    for_each = { for key, value in db_backup_config.value : key => value if key == "backup_destination_details" }
                    content {
                        #Optional
                        id   = lookup(backup_destination_details.value, "id", null)
                        type = lookup(backup_destination_details.value, "type", null)
                    }
                    }
                    recovery_window_in_days = lookup(db_backup_config, "recovery_window_in_days", null)
                }
            }
            db_domain = lookup(each.value.db_home.database, "db_domain", null)
            db_name = lookup(each.value.db_home.database, "db_name", null)
            db_workload = lookup(each.value.db_home.database, "db_workload", null)
            defined_tags = lookup(each.value.db_home.database, "defined_tags", null)
            freeform_tags = lookup(each.value.db_home.database, "freeform_tags", null)
            kms_key_id = lookup(each.value.db_home.database, "kms_key_id", null)
            kms_key_version_id = lookup(each.value.db_home.database, "kms_key_version_id", null)
            ncharacter_set = lookup(each.value.db_home.database, "ncharacter_set", null)
            pdb_name = lookup(each.value.db_home.database, "pdb_name", null)
#            sid_prefix = lookup(each.value.db_home.database, "sid_prefix", null)
            tde_wallet_password = lookup(each.value.db_home.database, "tde_wallet_password", null)
            time_stamp_for_point_in_time_recovery = lookup(each.value.db_home.database, "time_stamp_for_point_in_time_recovery", null)
            vault_id = lookup(each.value.db_home.database, "vault.id", null)
        }

        #Optional
        db_version = lookup(each.value.db_home, "db_version", null)
        defined_tags = lookup(each.value.db_home, "defined_tags", null)
        freeform_tags = lookup(each.value.db_home, "freeform_tags", null)
    }
   #Optional
    backup_network_nsg_ids = lookup(each.value, "backup_network_nsg_ids", null)
    backup_subnet_id = lookup(each.value, "backup_subnet_id", null)
    cluster_name = lookup(each.value, "cluster_name", null)
    cpu_core_count = lookup(each.value, "cpu_core_count", null)
    dynamic data_collection_options {
        for_each = { for key, value in each.value : key => value if key == "data_collection_options" }
        content {
            #Optional
            is_diagnostics_events_enabled = lookup(data_collection_options.value, "is_diagnostics_events_enabled", null)
            is_health_monitoring_enabled = lookup(data_collection_options.value, "is_health_monitoring_enabled", null)
            is_incident_logs_enabled = lookup(data_collection_options.value, "is_incident_logs_enabled", null)
        }
    }
    data_storage_percentage = lookup(each.value, "data_storage_percentage", null)
    data_storage_size_in_gb = lookup(each.value, "data_storage_size_in_gb", null)
    database_edition = lookup(each.value, "database_edition", null)
    dynamic db_system_options {
        for_each = { for key, value in each.value : key => value if key == "db_system_options" }

        content {
            #Optional
            storage_management = lookup(db_system_options.value, "storage_management", null)
        }
    }
    defined_tags           = lookup(each.value, "defined_tags", null)
    disk_redundancy = lookup(each.value, "disk_redundancy", null)
    display_name           = lookup(each.value, "name", each.key)
    domain = lookup(each.value, "domain", null)
    fault_domains = lookup(each.value, "fault_domains", null)
    freeform_tags          = lookup(each.value, "freeform_tags", null)
    kms_key_id = lookup(each.value, "kms_key_id", null)
    kms_key_version_id = lookup(each.value, "kms_key_version_id", null)
    license_model = lookup(each.value, "license_model", null)
    dynamic "maintenance_window_details" {
        for_each = { for key, value in each.value : key => value if key == "maintenance_window_details" }

        content {
        #Required
        preference = maintenance_window_details.value.preference

        #Optional
        custom_action_timeout_in_mins = lookup(maintenance_window_details.value, "custom_action_timeout_in_mins", 15)
        dynamic "days_of_week" {
            for_each = { for key, value in maintenance_window_details.value : key => value if key == "days_of_week" }
            content {
            #Required
            name = days_of_week.value.name
            }
        }
        hours_of_day                     = lookup(maintenance_window_details.value, "hours_of_day", null)
        is_custom_action_timeout_enabled = lookup(maintenance_window_details.value, "is_custom_action_timeout_enabled", false)
        is_monthly_patching_enabled      = lookup(maintenance_window_details.value, "is_monthly_patching_enabled", false)
        lead_time_in_weeks               = lookup(maintenance_window_details, "lead_time_in_weeks", null)
        dynamic "months" {
            for_each = lookup(maintenance_window_details.value, "months", {})
            #Required
            content {
            name = months.value.name
            }
        }
        patching_mode  = lookup(maintenance_window_details.value, "patching_mode", null)
        weeks_of_month = lookup(maintenance_window_details.value, "weeks_of_month", null)
        }
    }

    node_count = lookup(each.value, "node_count",1)
    nsg_ids = lookup(each.value, "nsg_ids", null)
    private_ip = lookup(each.value, "private_ip", null)
    source = lookup(each.value, "source", null)
    source_db_system_id = lookup(each.value, "source_db_system_id", null)
    sparse_diskgroup = lookup(each.value, "sparse_diskgroup", null)
    storage_volume_performance_mode = lookup(each.value, "storage_volume_performance_mode", null)
    time_zone = lookup(each.value, "time_zone", null)
}


data "oci_database_databases" "databases" {
  for_each = var.db_systems
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

    #Optional
    db_home_id = oci_database_db_system.db_system[each.key].db_home[0].id
}