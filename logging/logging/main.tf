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



resource "oci_logging_unified_agent_configuration" "unified_agent_configuration" {
  for_each = var.unified_agent_configurations

  #Required
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  is_enabled     = lookup(each.value, "is_enabled", true)
  description    = lookup(each.value, "description", each.key)
  display_name   = lookup(each.value, "name", each.key)

  service_configuration {
    #Required
    configuration_type = can(each.value.service_configuration.configuration_type) ? each.value.service_configuration.configuration_type : "LOGGING"

    destination {
      #Required
      log_object_id = oci_logging_log.log[each.value.service_configuration.destination.log_name].id
    }
    sources {
      #Required
      source_type = each.value.service_configuration.sources.source_type // can be either LOG_TAIL WINDOWS_EVENT_LOG or OCISERVICE

      #Optional
      channels = lookup(each.value.service_configuration.sources, "channels", null)
      name     = lookup(each.value.service_configuration.sources, "name", each.key)
      parser {
        #Required
        parser_type = each.value.service_configuration.sources.parser.parser_type

        #Optional
        delimiter                  = lookup(each.value.service_configuration.sources.parser, "delimiter", null)
        expression                 = lookup(each.value.service_configuration.sources.parser, "expression", null)
        field_time_key             = lookup(each.value.service_configuration.sources.parser, "field_time_key", null)
        format                     = lookup(each.value.service_configuration.sources.parser, "format", null)
        format_firstline           = lookup(each.value.service_configuration.sources.parser, "format_firstline", null)
        grok_failure_key           = lookup(each.value.service_configuration.sources.parser, "grok_failure_key", null)
        grok_name_key              = lookup(each.value.service_configuration.sources.parser, "grok_name_key", null)
        is_estimate_current_event  = lookup(each.value.service_configuration.sources.parser, "is_estimate_current_event", null)
        is_keep_time_key           = lookup(each.value.service_configuration.sources.parser, "is_keep_time_key", null)
        is_null_empty_string       = lookup(each.value.service_configuration.sources.parser, "is_null_empty_string", null)
        is_support_colonless_ident = lookup(each.value.service_configuration.sources.parser, "is_support_colonless_ident", null)
        is_with_priority           = lookup(each.value.service_configuration.sources.parser, "is_with_priority", null)
        keys                       = lookup(each.value.service_configuration.sources.parser, "keys", null)
        message_format             = lookup(each.value.service_configuration.sources.parser, "message_format", null)
        message_key                = lookup(each.value.service_configuration.sources.parser, "message_key", null)
        multi_line_start_regexp    = lookup(each.value.service_configuration.sources.parser, "multi_line_start_regexp", null)
        null_value_pattern         = lookup(each.value.service_configuration.sources.parser, "null_value_pattern", null)
        patterns {

          #Optional
          field_time_format = can(each.value.service_configuration.sources.parser.patterns) ? lookup(each.value.service_configuration.sources.parser.patterns, "field_time_format", null) : null
          field_time_key    = can(each.value.service_configuration.sources.parser.patterns) ? lookup(each.value.service_configuration.sources.parser.patterns, "field_time_key", null) : null
          field_time_zone   = can(each.value.service_configuration.sources.parser.patterns) ? lookup(each.value.service_configuration.sources.parser.patterns, "field_time_zone", null) : null
          name              = can(each.value.service_configuration.sources.parser.patterns) ? lookup(each.value.service_configuration.sources.parser.patterns, "name", null) : null
          pattern           = can(each.value.service_configuration.sources.parser.patterns) ? lookup(each.value.service_configuration.sources.parser.patterns, "pattern", null) : null
        }
        rfc5424time_format      = lookup(each.value.service_configuration.sources.parser, "rfc5424time_format", null)
        syslog_parser_type      = lookup(each.value.service_configuration.sources.parser, "syslog_parser_type", null)
        time_format             = lookup(each.value.service_configuration.sources.parser, "time_format", null)
        time_type               = lookup(each.value.service_configuration.sources.parser, "time_type", null)
        timeout_in_milliseconds = lookup(each.value.service_configuration.sources.parser, "timeout_in_milliseconds", null)
        types                   = lookup(each.value.service_configuration.sources.parser, "types", null)
      }
      paths = lookup(each.value.service_configuration.sources, "paths", null)
    }
  }

  #Optional
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)

  group_association {
    #Optional
    group_list = can(each.value.service_configuration.group_association) ? lookup(each.value.service_configuration.group_association, "group_list", null) : null
  }
}