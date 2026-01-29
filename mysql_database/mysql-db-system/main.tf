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
    dynamic "backup_policy" {
      for_each = { for key, value in each.value : key => value if key == "backup_policy" }
      content {
        #Optional
        dynamic "copy_policies" {
          for_each = { for key, value in backup_policy.value : key => value if key == "copy_policies" }
          content {
            #Required
            copy_to_region = copy_policies.value.copy_to_region

            #Optional
            backup_copy_retention_in_days = lookup(copy_policies.value, "backup_copy_retention_in_days", null)
          }
        }
        defined_tags = lookup(backup_policy.value, "defined_tags", null)
        freeform_tags = lookup(backup_policy.value, "freeform_tags", null)
        is_enabled = lookup(backup_policy.value, "is_enabled", null)
        pitr_policy {
            #Required
            is_enabled = lookup(backup_policy.value, "pitr_is_enabled", null)
        }
        retention_in_days = lookup(backup_policy.value, "retention_in_days", null)
        soft_delete = lookup(backup_policy.value, "soft_delete", null)
        window_start_time = lookup(backup_policy.value, "window_start_time", null)
      }
    }
    configuration_id = lookup(each.value, "configuration_id", null)
    crash_recovery = lookup(each.value, "crash_recovery", null)
    dynamic customer_contacts {
      for_each = lookup(each.value, "customer_contact_emails", {})
      content {
        #Required
        email = customer_contacts.value
      }
    }
    dynamic "data_storage" {
      for_each = { for key, value in each.value : key => value if key == "data_storage" }
      content {
        #Optional
        is_auto_expand_storage_enabled = lookup(data_storage.value, "is_auto_expand_storage_enabled", null)
        max_storage_size_in_gbs = lookup(data_storage.value, "max_storage_size_in_gbs", null)
      }
    }
    data_storage_size_in_gb = lookup(each.value, "data_storage_size_in_gb", null)
    database_management = lookup(each.value, "database_management", null)
    database_mode = lookup(each.value, "database_mode", null)
    defined_tags = lookup(each.value, "defined_tags", null)
    dynamic deletion_policy {
      for_each = lookup(each.value, "deletion_policy", {})
      content {
        #Optional
        automatic_backup_retention = lookup(each.value.deletion_policy, "automatic_backup_retention", null)
        final_backup = lookup(each.value.deletion_policy, "final_backup", null)
        is_delete_protected = lookup(each.value.deletion_policy, "is_delete_protected", null)
      }
    }
    description = lookup(each.value, "description", null)
    display_name = lookup(each.value, "display_name", each.key)
    dynamic "encrypt_data" {
      for_each = lookup(each.value, "encrypt_data", {})
      content {
        #Required
        key_generation_type = lookup(each.value.encrypt_data, "key_generation_type", null)

        #Optional
        key_id = lookup(each.value.encrypt_data, "key_id", null)
      }
    }
    fault_domain = lookup(each.value, "fault_domain", null)
    freeform_tags = lookup(each.value, "freeform_tags", null)
    hostname_label = lookup(each.value, "hostname_label", null)
    ip_address = lookup(each.value, "ip_address", null)
    is_highly_available = lookup(each.value, "is_highly_available", null)
    dynamic "maintenance" {
      for_each = lookup(each.value, "maintenance", {})
      content {
        #Required
        window_start_time = lookup(each.value.maintenance, "window_start_time", null)

        #Optional
        maintenance_schedule_type = lookup(each.value.maintenance, "maintenance_schedule_type", null)
        version_preference = lookup(each.value.maintenance, "version_preference", null)
        version_track_preference = lookup(each.value.maintenance, "version_track_preference", null)
      }
    }
    nsg_ids = lookup(each.value, "nsg_ids", null)
    port = lookup(each.value, "port", null)
    port_x = lookup(each.value, "port_x", null)
    dynamic "read_endpoint" {
      for_each = { for key, value in each.value : key => value if key == "read_endpoint"}
      content {
        #Optional
        exclude_ips = lookup(read_endpoint.value, "exclude_ips", null)
        is_enabled = lookup(read_endpoint.value, "is_enabled", null)
        read_endpoint_hostname_label = lookup(read_endpoint.value, "hostname_label", null)
        read_endpoint_ip_address = lookup(read_endpoint.value, "ip_address", null)
      }
    }
    dynamic "rest" {
      for_each = lookup(each.value, "rest", {})
      content {
        #Required
        configuration = lookup(each.value, "rest_configuration", null)

        #Optional
        port = lookup(each.value, "rest_port", null)
      }
    }
    dynamic "secure_connections" {
      for_each = { for key, value in each.value : key => value if key == "secure_connections"}
        content {
        #Required
        certificate_generation_type = lookup(each.value, "certificate_generation_type", null)

        #Optional
        certificate_id = lookup(each.value, "certificate_id", null)
      }
    }
    security_attributes = lookup(each.value, "security_attributes", null)
    dynamic "source" {
      for_each = lookup(each.value, "source", {})
      content {
        #Required
        source_type = lookup(source.value, "source_type", null)

        #Optional
        ## Required if source_type is BACKUP
        backup_id = lookup(source.value, "backup_id", null)
        ## Required if source_type is PITR
        db_system_id = lookup(source.value, "db_system_id", null)
        recovery_point = lookup(source.value, "recovery_point", null)
        ## Required if source_type is IMPORTURL
        source_url = lookup(source.value, "source_url", null)
      }
    }
}