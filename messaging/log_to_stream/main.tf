resource "oci_sch_service_connector" "service_connector" {
    for_each = var.service_connectors

    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    display_name   = lookup(each.value, "name", each.key)

    source {
        kind = "logging"
        dynamic log_sources {
            for_each = { for key, value in each.value : key => value if key == "log_sources" }
            content {
                compartment_id = log_sources.value.compartment_id
                log_group_id   = oci_logging_log_group.log_group[log_sources.value.log_group_name].id
                log_id         = can(oci_logging_log.log[log_sources.value.log_name].id) ? oci_logging_log.log[log_sources.value.log_name].id : null
            }
        }
        log_sources {
            compartment_id = each.value.tenancy_id
            log_group_id   = "_Audit_Include_Subcompartment"
        }
    }

    target {
        kind = "streaming"
        stream_id = oci_streaming_stream.stream[each.value.target_stream_name].id
        compartment_id = lookup(each.value, "target_compartment_id",  lookup(each.value, "compartment_id", var.compartment_id))
    }
}

resource "oci_streaming_stream" "stream" {
    for_each = var.streams

    #Required
    name = lookup(each.value, "name", each.key)
    partitions = lookup(each.value, "partitions", 1)

    #Optional
#    compartment_id = lookup(each.value, "compartment_id", null)
    defined_tags = lookup(each.value, "defined_tags", null)
    freeform_tags = lookup(each.value, "freeform_tags", null)
    retention_in_hours = lookup(each.value, "retention_in_hours", "24")
    stream_pool_id = can(oci_streaming_stream_pool.stream_pool[each.value.stream_pool_name].id) ? oci_streaming_stream_pool.stream_pool[each.value.stream_pool_name].id : null
}

resource "oci_streaming_stream_pool" "stream_pool" {
    for_each = var.stream_pools

    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

    dynamic "custom_encryption_key" {
    for_each = { for key, value in each.value : key => value if key == "custom_encryption_key" }
        content {
            kms_key_id = custom_encryption_key.value.kms_key_id
        }
    }
    freeform_tags      = lookup(each.value, "freeform_tags", null)
    defined_tags       = lookup(each.value, "defined_tags", null)

    kafka_settings {
        auto_create_topics_enable = lookup(each.value, "kafka_settings_auto_create_topics_enable", false)
        log_retention_hours       = lookup(each.value, "kafka_settings_log_retention_hours", "24")
        num_partitions            = lookup(each.value, "kafka_settings_num_partitions", "1")
    }

    name = lookup(each.value, "name", each.key)
    dynamic "private_endpoint_settings" {
        for_each = { for key, value in each.value : key => value if key == "private_endpoint_settings" }

        content {
            #Optional
            nsg_ids = lookup(private_endpoint_settings.value, "nsg_ids", null)
            private_endpoint_ip = lookup(private_endpoint_settings.value, "private_endpoint_ip", null)
            subnet_id = lookup(private_endpoint_settings.value, "subnet_id", null)
        }
    }
}

resource "oci_logging_log_group" "log_group" {
  for_each = var.log_groups
  #Required
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  display_name   = lookup(each.value, "name", each.key)

  #Optional
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
  description   = lookup(each.value, "description", null)
}


resource "oci_logging_log" "log" {
  for_each = var.logs
  #Required
  display_name = lookup(each.value, "name", each.key)
  log_group_id = oci_logging_log_group.log_group[each.value.log_group_name].id
  log_type     = each.value.log_type // can be either CUSTOM or SERVICE 

  #Optional
  dynamic "configuration" {
    for_each = { for key, value in each.value : key => value if key == "configuration" }

    #Required
    content {
      source {
        #Required
        category    = configuration.value.source.category
        resource    = configuration.value.source.resource
        service     = configuration.value.source.service
        source_type = configuration.value.source.source_type
      }

      #Optional
      compartment_id = lookup(configuration.value, "compartment_id", var.compartment_id)
    }
  }
  freeform_tags      = lookup(each.value, "freeform_tags", null)
  defined_tags       = lookup(each.value, "defined_tags", null)
  is_enabled         = lookup(each.value, "is_enabled", true)
  retention_duration = lookup(each.value, "retention_duration", 30)
}

resource "oci_logging_log" "service_collector_log" {
  for_each = var.service_connectors
  #Required
  display_name = "${lookup(each.value, "name", each.key)}_runlog"
  log_group_id = oci_logging_log_group.service_connector_log_group[each.key].id
  log_type     = "SERVICE"

  #Optional
   configuration {

    #Required
      source {
        #Required
        category    = "runlog"
        resource    = oci_sch_service_connector.service_connector[each.key].id
        service     = "och"
        source_type = "OCISERVICE"
      }
      #Optional
      compartment_id = can(each.value.service_connector_log_compartment_id) ? each.value.service_connector_log_compartment_id : var.compartment_id
  }
  freeform_tags      = lookup(each.value, "service_connector_log_freeform_tags", null)
  defined_tags       = lookup(each.value, "service_connector_log_defined_tags", null)
  is_enabled         = lookup(each.value, "service_connector_log_is_enabled", true)
  retention_duration = lookup(each.value, "service_connector_log_retention_duration", 30)
}

resource "oci_logging_log_group" "service_connector_log_group" {
  for_each = var.service_connectors
  #Required
  compartment_id = lookup(each.value, "service_connector_log_compartment_id", var.compartment_id)
  display_name   = each.value.service_connector_log_group_name

  #Optional
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
  description   = lookup(each.value, "description", null)
}