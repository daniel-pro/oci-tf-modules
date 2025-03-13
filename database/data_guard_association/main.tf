data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

resource "oci_database_data_guard_association" "data_guard_association" {
    for_each = var.data_guard_associations
    #Required
    creation_type = lookup(each.value, "creation_type", "NewDbSystem")
    database_admin_password = each.value.database_admin_password
    database_id = each.value.database_id
    delete_standby_db_home_on_delete = lookup(each.value, "delete_standby_db_home_on_delete", "true")
    protection_mode = lookup(each.value, "protection_mode", "MAXIMUM_PERFORMANCE") 
    transport_type = lookup(each.value, "transport_type", "ASYNC")

    #Optional
    # availability_domain = data.oci_identity_availability_domains.ad.availability_domains[lookup(each.value, "availability_domain", "1") - 1].name
    availability_domain = lookup(each.value, "availability_domain", null)
    backup_network_nsg_ids = lookup(each.value, "backup_network_nsg_ids", null)
    cpu_core_count = lookup(each.value, "cpu_core_count", null)
    database_defined_tags = lookup(each.value, "defined_tags", null)
    database_freeform_tags = lookup(each.value, "freeform_tags", null)
    dynamic data_collection_options {
        for_each = lookup(each.value, "data_collection_options", {})
        content {
            #Optional
            is_diagnostics_events_enabled = lookup(customer_contacts.value, "is_diagnostics_events_enabled", null)
            is_health_monitoring_enabled = lookup(customer_contacts.value, "is_health_monitoring_enabled", null)
            is_incident_logs_enabled =  lookup(customer_contacts.value, "is_incident_logs_enabled", null)
        }
    }
    database_software_image_id = lookup(each.value, "database_software_image_id", null)
    db_system_defined_tags = lookup(each.value, "db_system_defined_tags", null)
    db_system_freeform_tags = lookup(each.value, "db_system_freeform_tags", null)
    db_system_security_attributes = lookup(each.value, "db_system_security_attributes", null)
    display_name = lookup(each.value, "display_name", null)
    domain = lookup(each.value, "domain", null)
    fault_domains = lookup(each.value, "fault_domains", null)
    hostname = lookup(each.value, "hostname", null)
    is_active_data_guard_enabled = lookup(each.value, "is_active_data_guard_enabled", null)
    license_model = lookup(each.value, "license_model", null)
    node_count = lookup(each.value, "node_count", null)
    nsg_ids = lookup(each.value, "nsg_ids", null)
    peer_db_home_id =  lookup(each.value, "peer_db_home_id", null)
    peer_db_system_id =  lookup(each.value, "peer_db_system.id", null)
    peer_db_unique_name = lookup(each.value, "peer_db_unique_name", null)
    peer_sid_prefix = lookup(each.value, "peer_sid_prefix", null)
    peer_vm_cluster_id =  lookup(each.value, "peer_vm_cluster_id", null)
    private_ip = lookup(each.value, "private_ip", null)
    # private_ip_v6 = lookup(each.value, "private_ip_v6", null)
    shape = lookup(each.value, "shape", null)
    storage_volume_performance_mode = lookup(each.value, "storage_volume_performance_mode", null)
    subnet_id =  lookup(each.value, "subnet_id", null)
    time_zone = lookup(each.value, "time_zone", null)
}