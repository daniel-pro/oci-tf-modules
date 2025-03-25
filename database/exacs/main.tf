data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_database_cloud_exadata_infrastructure" "cloud_exadata_infrastructure" {
  for_each = var.cloud_exadata_infrastructures
  #Required
  availability_domain = edata.oci_identity_availability_domains.ad.availability_domains[each.value.availability_domain - 1].name
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
  cloud_exadata_infrastructure_id = oci_database_cloud_exadata_infrastructure.cloud_exadata_infrastructure[each.value.cloud_exadata_infrastructure_name].id
  compartment_id                  = lookup(each.value, "compartment_id", var.compartment_id)
  cpu_core_count                  = each.value.cpu_core_count
  display_name                    = each.value.name
  gi_version                      = each.value.gi_version
  hostname                        = each.value.hostname
  ssh_public_keys                 = each.value.ssh_public_keys
  subnet_id                       = each.value.subnet_id

  #Optional
  backup_network_nsg_ids = lookup(each.value, "backup_network_nsg_ids", null)
  cluster_name           = lookup(each.value, "cluster_name", null)
  dynamic "data_collection_options" {
    for_each = lookup(each.value, "data_collection_options", {})
    content {
      #Optional
      is_diagnostics_events_enabled = data_collection_options.is_diagnostics_events_enabled
    }
  }
  data_storage_percentage     = lookup(each.value, "data_storage_percentage", null)
  defined_tags                = lookup(each.value, "defined_tags", null)
  domain                      = lookup(each.value, "domain", null)
  freeform_tags               = lookup(each.value, "freeform_tags", null)
  is_local_backup_enabled     = lookup(each.value, "is_local_backup_enabled", false)
  is_sparse_diskgroup_enabled = lookup(each.value, "is_sparse_diskgroup_enabled", false)
  license_model               = lookup(each.value, "license_model", "BRING_YOUR_OWN_LICENSE") #must be either BRING_YOUR_OWN_LICENSE or LICENSE_INCLUDED
  nsg_ids                     = lookup(each.value, "nsg_ids", null)
  ocpu_count                  = lookup(each.value, "ocpu_count", null)
  scan_listener_port_tcp      = lookup(each.value, "scan_listener_port_tcp", 1521)
  scan_listener_port_tcp_ssl  = lookup(each.value, "scan_listener_port_tcp_ssl", 2484)
  time_zone                   = lookup(each.value, "time_zone", "UTC")
}

resource "oci_database_db_home" "db_home" {
  for_each = var.db_homes
  #Required
  database {
    #Required
    admin_password = each.value.database.admin_password

    #Optional
    backup_id                  = lookup(each.value.database, "backup_id", null)
    backup_tde_password        = lookup(each.value.database, "backup_tde_password", null)
    character_set              = lookup(each.value.database, "character_set", null)
    database_id                = lookup(each.value.database, "database_id", null)
    database_software_image_id = lookup(each.value.database, "database_software_image_id", null)
    dynamic "db_backup_config" {
      for_each = { for key, value in each.value.database : key => value if key == "db_backup_config" }
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
    db_name                               = lookup(each.value.database, "db_name", null)
    db_workload                           = lookup(each.value.database, "db_workload", null)
    defined_tags                          = lookup(each.value.database, "defined_tags", null)
    freeform_tags                         = lookup(each.value.database, "freeform_tags", null)
    kms_key_id                            = lookup(each.value.database, "kms_key_id", null)
    kms_key_version_id                    = lookup(each.value.database, "kms_key_version_id", null)
    ncharacter_set                        = lookup(each.value.database, "ncharacter_set", null)
    pdb_name                              = lookup(each.value.database, "pdb_name", null)
    sid_prefix                            = lookup(each.value.database, "sid_prefix", null)
    tde_wallet_password                   = lookup(each.value.database, "tde_wallet_password", null)
    time_stamp_for_point_in_time_recovery = lookup(each.value.database, "time_stamp_for_point_in_time_recovery", null)
    vault_id                              = lookup(each.value.database, "vault_id", null)
  }

  #Optional
  database_software_image_id = lookup(each.value, "database_software_image_id", null)
  db_system_id               = lookup(each.value, "db_system_id", null)
  db_version                 = lookup(each.value, "db_version", null)
  defined_tags           = lookup(each.value, "defined_tags", null)
  display_name           = lookup(each.value, "name", each.key)
  freeform_tags          = lookup(each.value, "freeform_tags", null)
  is_desupported_version = lookup(each.value, "is_desupported_version", null)
  kms_key_id             = lookup(each.value, "kms_key_id", null)
  kms_key_version_id     = lookup(each.value, "kms_key_version_id", null)
  source                 = lookup(each.value, "source", "NONE") #The source of database: NONE for creating a new database. DB_BACKUP for creating a new database by restoring from a database backup. VM_CLUSTER_NEW for creating a database for VM Cluster.
  vm_cluster_id          = oci_database_cloud_vm_cluster.cloud_vm_cluster[each.value.vm_cluster_name].id
}