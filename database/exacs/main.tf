data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

data "oci_database_db_servers" "db_servers" {
  for_each = var.cloud_vm_clusters
  compartment_id = var.compartment_id
  exadata_infrastructure_id = can(each.value.cloud_exadata_infrastructure_id) ? each.value.cloud_exadata_infrastructure_id : oci_database_cloud_exadata_infrastructure.cloud_exadata_infrastructure[each.value.cloud_exadata_infrastructure_name].id
}

resource "oci_database_cloud_exadata_infrastructure" "cloud_exadata_infrastructure" {
  for_each = var.cloud_exadata_infrastructures
  #Required
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[each.value.availability_domain - 1].name
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  display_name        = each.value.name
  shape               = each.value.shape

  #Optional
  compute_count = lookup(each.value, "compute_count", 2)

  dynamic "customer_contacts" {
    for_each = lookup(each.value, "customer_contacts", {})
    #Optional
    content {
      email = customer_contacts.value.email
    }
  }
  defined_tags  = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)

  dynamic "maintenance_window" {
    for_each = { for key, value in each.value : key => value if key == "maintenance_window" }

    content {
      #Required
      preference = maintenance_window.value.preference

      #Optional
      custom_action_timeout_in_mins = lookup(maintenance_window.value, "custom_action_timeout_in_mins", 15)
      dynamic "days_of_week" {
        for_each = lookup(maintenance_window.value, "days_of_week", {})
        content {
          #Required
          name = days_of_week.value.name
        }
      }
      hours_of_day                     = lookup(maintenance_window.value, "hours_of_day", null)
      is_custom_action_timeout_enabled = lookup(maintenance_window.value, "is_custom_action_timeout_enabled", false)
      lead_time_in_weeks               = lookup(maintenance_window.value, "lead_time_in_weeks", null)
      dynamic "months" {
        for_each = lookup(maintenance_window.value, "months", {})
        #Required
        content {
          name = months.value.name
        }
      }
      patching_mode  = lookup(maintenance_window.value, "patching_mode", null)
      weeks_of_month = lookup(maintenance_window.value, "weeks_of_month", null)
    }
  }

  storage_count = lookup(each.value, "storage_count", 3)
}

resource "oci_database_cloud_vm_cluster" "cloud_vm_cluster" {
  for_each = var.cloud_vm_clusters

  #Required
  backup_subnet_id                = each.value.backup_subnet_id
  cloud_exadata_infrastructure_id = can(each.value.cloud_exadata_infrastructure_id) ? each.value.cloud_exadata_infrastructure_id : oci_database_cloud_exadata_infrastructure.cloud_exadata_infrastructure[each.value.cloud_exadata_infrastructure_name].id
  compartment_id                  = lookup(each.value, "compartment_id", var.compartment_id)
  cpu_core_count                  = each.value.cpu_core_count
  display_name                    = each.value.name
  gi_version                      = each.value.gi_version
  hostname                        = each.value.hostname
  ssh_public_keys                 = each.value.ssh_public_keys
  subnet_id                       = each.value.subnet_id

  #Optional
  backup_network_nsg_ids = lookup(each.value, "backup_network_nsg_ids", null)
  dynamic cloud_automation_update_details {
    for_each = lookup(each.value, "cloud_automation_update_details", {})
    content {
        #Optional
        apply_update_time_preference {

            #Optional
            apply_update_preferred_end_time = lookup(cloud_automation_update_details.value, "apply_update_preferred_end_time", null)
            apply_update_preferred_start_time = lookup(cloud_automation_update_details.value, "apply_update_preferred_start_time", null)
        }
        freeze_period {

            #Optional
            freeze_period_end_time = lookup(cloud_automation_update_details.value, "freeze_period_end_time", null)
            freeze_period_start_time = lookup(cloud_automation_update_details.value, "freeze_period_start_time", null)
        }
        is_early_adoption_enabled = lookup(cloud_automation_update_details.value, "is_early_adoption_enabled", null)
        is_freeze_period_enabled = lookup(cloud_automation_update_details.value, "is_freeze_period_enabled", null)
    }
  }
  cluster_name           = lookup(each.value, "cluster_name", null)
  dynamic "data_collection_options" {
    for_each = lookup(each.value, "data_collection_options", {})
    content {
      #Optional
      is_diagnostics_events_enabled = data_collection_options.is_diagnostics_events_enabled
    }
  }
  data_storage_percentage     = lookup(each.value, "data_storage_percentage", null)
  data_storage_size_in_tbs    = lookup(each.value, "data_storage_size_in_tbs", null)
  db_node_storage_size_in_gbs = lookup(each.value, "db_node_storage_size_in_gbs", null)
  db_servers = data.oci_database_db_servers.db_servers[each.key].db_servers[*].id
  defined_tags                = lookup(each.value, "defined_tags", null)
  domain                      = lookup(each.value, "domain", null)
  dynamic file_system_configuration_details {
    for_each = lookup(each.value, "file_system_configuration_details", {})
    content {
        #Optional
        file_system_size_gb = lookup(file_system_configuration_details.value, "file_system_size_gb", null)
        mount_point = can(file_system_configuration_details.key) ? file_system_configuration_details.key : null
    }
  }
  freeform_tags               = lookup(each.value, "freeform_tags", null)
  is_local_backup_enabled     = lookup(each.value, "is_local_backup_enabled", false)
  is_sparse_diskgroup_enabled = lookup(each.value, "is_sparse_diskgroup_enabled", false)
  license_model               = lookup(each.value, "license_model", null) #must be either BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED
  memory_size_in_gbs          = lookup(each.value, "memory_size_in_gbs", null)
  nsg_ids                     = lookup(each.value, "nsg_ids", null)
  ocpu_count                  = lookup(each.value, "ocpu_count", null)
  private_zone_id             = lookup(each.value, "private_zone_id", null)
  scan_listener_port_tcp      = lookup(each.value, "scan_listener_port_tcp", 1521)
  scan_listener_port_tcp_ssl  = lookup(each.value, "scan_listener_port_tcp_ssl", 2484)
  security_attributes         = lookup(each.value, "security_attributes", null)
  subscription_id             = lookup(each.value, "subscription_id", null)
  system_version              = lookup(each.value, "system_version", null)
  time_zone                   = lookup(each.value, "time_zone", null)
### Returned Unsupported Error on 31-Mar-2025   vm_cluster_type             = lookup(each.value, "vm_cluster_type", null)
}

resource "oci_database_db_home" "db_home" {
  for_each = var.db_homes
  #Required
  #Optional
  database_software_image_id = lookup(each.value, "database_software_image_id", null)
  db_system_id               = lookup(each.value, "db_system_id", null)
  db_version                 = lookup(each.value, "db_version", null)
  defined_tags               = lookup(each.value, "defined_tags", null)
  display_name               = lookup(each.value, "name", each.key)
  freeform_tags              = lookup(each.value, "freeform_tags", null)
  is_desupported_version     = lookup(each.value, "is_desupported_version", null)
  kms_key_id                 = lookup(each.value, "kms_key_id", null)
  kms_key_version_id         = lookup(each.value, "kms_key_version_id", null)
  source                     = lookup(each.value, "source", "NONE") #The source of database: NONE for creating a new database. DB_BACKUP for creating a new database by restoring from a database backup. VM_CLUSTER_NEW for creating a database for VM Cluster.
  vm_cluster_id              = can(each.value.vm_cluster_id) ? each.value.vm_cluster_id : oci_database_cloud_vm_cluster.cloud_vm_cluster[each.value.vm_cluster_name].id 
}

resource "oci_database_database" "database" {
    for_each = var.databases
    #Required
    database {
        #Required
        admin_password = each.value.admin_password
        db_name = each.value.db_name

        #Optional
        backup_id = lookup(each.value, "backup_id", null)
        backup_tde_password = lookup(each.value, "backup_tde_password", null)
        character_set = lookup(each.value, "character_set", null)
        database_software_image_id = lookup(each.value, "database_software_image_id", null)
        dynamic db_backup_config {
          for_each = lookup(each.value, "db_backup_config", {})
          content {
            #Optional
            auto_backup_enabled = lookup(db_backup_config.value, "auto_backup_enabled", null)
            auto_backup_window = lookup(db_backup_config.value, "auto_backup_window", null)
            auto_full_backup_day = lookup(db_backup_config.value, "auto_full_backup_day", null)
            auto_full_backup_window = lookup(db_backup_config.value, "auto_full_backup_window", null)
            backup_deletion_policy = lookup(db_backup_config.value, "backup_deletion_policy", null)
            dynamic backup_destination_details {
              for_each = lookup(each.value, "backup_destination_details", {})
              content {
                #Optional
                dbrs_policy_id = lookup(backup_destination_details.value, "dbrs_policy_id", null)
                id = lookup(backup_destination_details.value, "id", null)
                type = lookup(backup_destination_details.value, "type", null)
              }
            }
            recovery_window_in_days = lookup(db_backup_config.value, "recovery_window_in_days", null)
            run_immediate_full_backup = lookup(db_backup_config.value, "run_immediate_full_backup", null)
          }
        }
        db_unique_name = lookup(each.value, "db_unique_name", null)
        db_workload = lookup(each.value, "db_workload", null)
        defined_tags = lookup(each.value, "defined_tags", null)
### Returned Unsupported Error on 31-Mar-2025 dynamic encryption_key_location_details {
### Returned Unsupported Error on 31-Mar-2025   for_each = lookup(each.value, "encryption_key_location_details", {})
### Returned Unsupported Error on 31-Mar-2025   content {
### Returned Unsupported Error on 31-Mar-2025     #Required
### Returned Unsupported Error on 31-Mar-2025     hsm_password = lookup(encryption_key_location_details.value, "hsm_password", null)
### Returned Unsupported Error on 31-Mar-2025     provider_type = lookup(encryption_key_location_details.value, "provider_type", null)
### Returned Unsupported Error on 31-Mar-2025   }
### Returned Unsupported Error on 31-Mar-2025 }
        freeform_tags = lookup(each.value, "freeform_tags", null)
### Returned Unsupported Error on 31-Mar-2025 key_store_id = lookup(each.value, "key_store_id", null)
### Returned Unsupported Error on 31-Mar-2025 is_active_data_guard_enabled = lookup(each.value, "is_active_data_guard_enabled", null)
        kms_key_id = lookup(each.value, "kms_key_id", null)
        kms_key_version_id = lookup(each.value, "kms_key_version_id", null)
        ncharacter_set = lookup(each.value, "ncharacter_set", null)
        pdb_name = lookup(each.value, "pdb_name", null)
        pluggable_databases = lookup(each.value, "pluggable_databases", null)
### Returned Unsupported Error on 31-Mar-2025 protection_mode = lookup(each.value, "protection_mode", null)
        sid_prefix = lookup(each.value, "sid_prefix", null)
### Returned Unsupported Error on 31-Mar-2025 source_database_id = lookup(each.value, "source_database_id", null)
### Returned Unsupported Error on 31-Mar-2025 source_tde_wallet_password = lookup(each.value, "source_tde_wallet_password", null)
### Returned Unsupported Error on 31-Mar-2025 dynamic source_encryption_key_location_details {
### Returned Unsupported Error on 31-Mar-2025   for_each = lookup(each.value, "source_encryption_key_location_details", {})
### Returned Unsupported Error on 31-Mar-2025   content {
### Returned Unsupported Error on 31-Mar-2025     #Required
### Returned Unsupported Error on 31-Mar-2025     hsm_password = lookup(source_encryption_key_location_details.value, "hsm_password", null)
### Returned Unsupported Error on 31-Mar-2025     provider_type = lookup(source_encryption_key_location_details.value, "provider_type", null)
### Returned Unsupported Error on 31-Mar-2025   }
### Returned Unsupported Error on 31-Mar-2025 }
        tde_wallet_password = lookup(each.value, "tde_wallet_password", null)
### Returned Unsupported Error on 31-Mar-2025 transport_type = lookup(each.value, "transport_type", null)
        vault_id = lookup(each.value, "vault_id", null)
    }
    db_home_id = can(each.value.db_home_id) ? each.value.db_home_id : oci_database_db_home.db_home[each.value.db_home_name].id
    source = lookup(each.value, "source", null)

    #Optional
    db_version =lookup(each.value, "db_version", null)
    kms_key_id = lookup(each.value, "kms_key_id", null)
    kms_key_version_id = lookup(each.value, "kms_key_version_id", null)
}
