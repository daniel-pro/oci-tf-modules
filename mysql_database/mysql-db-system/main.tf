data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_mysql_mysql_db_system" "mysql_db_system" {
  for_each = var.mysql_db_systems
    #Required
    availability_domain = data.oci_identity_availability_domains.ad.availability_domains[each.value.availability_domain - 1].name
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    shape_name = each.value.shape_name
    subnet_id = each.value.subnet_id

    #Optional
    access_mode = lookup(each.value, "access_mode", null)
    admin_password = lookup(each.value, "admin_password", null)
    admin_username = lookup(each.value, "admin_username", null)
    backup_policy {
      #Optional
      dynamic "copy_policies" {
        for_each = { for key, value in each.value.backup_policy : key => value if key == "copy_policies" }
        content {
          #Required
          copy_to_region = copy_policies.value.copy_to_region

          #Optional
          backup_copy_retention_in_days = lookup(copy_policies.value, "backup_copy_retention_in_days", null)
        }
      }
      defined_tags = lookup(each.value.backup_policy, "defined_tags", null)
      freeform_tags = lookup(each.value.backup_policy, "freeform_tags", null)
      is_enabled = lookup(each.value.backup_policy, "is_enabled", null)
      pitr_policy {
          #Required
          is_enabled = lookup(each.value.backup_policy.pitr_policy, "is_enabled", null)
      }
      retention_in_days = lookup(each.value.backup_policy, "retention_in_days", null)
      soft_delete = lookup(each.value.backup_policy, "soft_delete", null)
      window_start_time = lookup(each.value.backup_policy, "window_start_time", null)
    }
    configuration_id = lookup(each.value, "configuration_id", null)
    crash_recovery = lookup(each.value, "crash_recovery", null)
    dynamic customer_contacts {
      for_each = lookup(each.value, "customer_contacts", {})
      content {
        #Required
        email = customer_contacts.value.email
      }
    }
    data_storage {
      #Optional
      is_auto_expand_storage_enabled = lookup(each.value.data_storage, "is_auto_expand_storage_enabled", null)
      max_storage_size_in_gbs = lookup(each.value.data_storage, "max_storage_size_in_gbs", null)
    }
    data_storage_size_in_gb = lookup(each.value, "data_storage_size_in_gb", null)
    database_management = lookup(each.value, "database_management", null)
    database_mode = lookup(each.value, "database_mode", null)
    defined_tags = lookup(each.value, "defined_tags", null)
    deletion_policy {
        #Optional
        automatic_backup_retention = lookup(each.value.deletion_policy, "automatic_backup_retention", null)
        final_backup = lookup(each.value.deletion_policy, "final_backup", null)
        is_delete_protected = lookup(each.value.deletion_policy, "is_delete_protected", null)
    }
    description = lookup(each.value, "description", null)
    display_name = lookup(each.value, "display_name", each.key)
    encrypt_data {
        #Required
        key_generation_type = lookup(each.value.encrypt_data, "key_generation_type", null)

        #Optional
        key_id = lookup(each.value.encrypt_data, "key_id", null)
    }
    fault_domain = lookup(each.value, "fault_domain", null)
    freeform_tags = lookup(each.value, "freeform_tags", null)
    hostname_label = lookup(each.value, "hostname_label", null)
    ip_address = lookup(each.value, "ip_address", null)
    is_highly_available = lookup(each.value, "is_highly_available", null)
    maintenance {
      #Required
      window_start_time = lookup(each.value.maintenance, "window_start_time", null)

      #Optional
      maintenance_schedule_type = lookup(each.value.maintenance, "maintenance_schedule_type", null)
      version_preference = lookup(each.value.maintenance, "version_preference", null)
      version_track_preference = lookup(each.value.maintenance, "version_track_preference", null)
    }
    nsg_ids = lookup(each.value, "nsg_ids", null)
    port = lookup(each.value, "port", null)
    port_x = lookup(each.value, "port_x", null)
    read_endpoint {
      #Optional
      exclude_ips = lookup(each.value.read_endpoint, "exclude_ips", null)
      is_enabled = lookup(each.value.read_endpoint, "is_enabled", null)
      read_endpoint_hostname_label = lookup(each.value.read_endpoint, "read_endpoint_hostname_label", null)
      read_endpoint_ip_address = lookup(each.value.read_endpoint, "read_endpoint_ip_address", null)
    }
    rest {
      #Required
      configuration = lookup(each.value.rest, "configuration", null)

      #Optional
      port = lookup(each.value.rest, "port", null)
    }
    secure_connections {
        #Required
        certificate_generation_type = lookup(each.value.secure_connections, "certificate_generation_type", null)

        #Optional
        certificate_id = lookup(each.value.secure_connections, "certificate_id", null)
    }
    security_attributes = lookup(each.value, "security_attributes", null)
    source {
        #Required
        source_type = lookup(each.value.source, "source_type", null)

        #Optional
        ## Required if source_type is BACKUP
        backup_id = lookup(each.value.source, "backup_id", null)
        ## Required if source_type is PITR
        db_system_id = lookup(each.value.source, "db_system_id", null)
        recovery_point = lookup(each.value.source, "recovery_point", null)
        ## Required if source_type is IMPORTURL
        source_url = lookup(each.value.source, "source_url", null)
    }
}