resource "oci_waf_web_app_firewall" "web_app_firewall" {
  for_each = var.web_app_firewalls
  #Required
  backend_type               = lookup(each.value, "backend_type", "LOAD_BALANCER")
  compartment_id             = lookup(each.value, "compartment_id", var.compartment_id)
  load_balancer_id           = each.value.load_balancer_id
  web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.web_app_firewall_policy[each.value.web_app_firewall_policy_name].id

  #Optional
  display_name  = lookup(each.value, "display_name", each.key)
  defined_tags  = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)
  system_tags   = lookup(each.value, "system_tags", null)
}

resource "oci_waf_web_app_firewall_policy" "web_app_firewall_policy" {
  for_each = var.web_app_firewall_policies
  #Required
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

  #Optional
  dynamic "actions" {
    for_each = lookup(each.value, "actions", {})
    #Required
    content {
      name = actions.value.name
      type = actions.value.type

      #Optional
      dynamic "body" {
        for_each = { for key, value in actions.value : key => value if key == "body" }
        content {
          #Required
          text = body.value.text
          type = body.value.type
        }
      }
      code = lookup(actions.value, "code", null)
      dynamic "headers" {
        for_each = lookup(actions.value, "headers", {})
        content {
          #Optional
          name  = lookup(headers.value, "name", null)
          value = lookup(headers.value, "value", null)
        }
      }
    }
  }

  defined_tags  = lookup(each.value, "defined_tags", null)
  display_name  = lookup(each.value, "display_name", each.key)
  freeform_tags = lookup(each.value, "freeform_tags", null)
  dynamic "request_access_control" {
    for_each = { for key, value in each.value : key => value if key == "request_access_control" }
    content {
      #Required
      default_action_name = request_access_control.value.default_action_name

      #Optional
      dynamic "rules" {
        for_each = lookup(request_access_control.value, "rules", {})
        content {
          #Required
          action_name = rules.value.action_name
          name        = rules.value.name
          type        = rules.value.type

          #Optional
          condition          = lookup(rules.value, "condition", null)
          condition_language = lookup(rules.value, "condition_language", null)
        }
      }
    }
  }
  dynamic "request_protection" {
    for_each = { for key, value in each.value : key => value if key == "request_protection" }
    content {
      #Optional
      body_inspection_size_limit_exceeded_action_name = lookup(request_protection.value, "body_inspection_size_limit_exceeded_action_name", null)
      body_inspection_size_limit_in_bytes             = lookup(request_protection.value, "body_inspection_size_limit_in_bytes", null)
      dynamic "rules" {
        for_each = lookup(request_protection.value, "rules", {})
        content {
          #Required
          action_name = rules.value.action_name
          name        = rules.value.name
          dynamic "protection_capabilities" {
            for_each = lookup(rules.value, "protection_capabilities", {})
            content {
              #Required
              key     = protection_capabilities.key
              version = protection_capabilities.value.version

              #Optional
              action_name                    = lookup(rules.value.protection_capabilities, "action_name", null)
              collaborative_action_threshold = lookup(rules.value.protection_capabilities, "collaborative_action_threshold", null)
              dynamic "collaborative_weights" {
                for_each = lookup(rules.value.protection_capabilities, "collaborative_weights", {})
                content {
                  #Required
                  key    = collaborative_weights.key
                  weight = collaborative_weights.value.weight
                }
              }
              dynamic "exclusions" {
                for_each = lookup(rules.value.protection_capabilities, "exclusions", {})
                content {
                  #Optional
                  args            = lookup(exclusions.value, "args", null)
                  request_cookies = lookup(exclusions.value, "request_cookies", null)
                }
              }
            }
          }
          type = rules.value.type # Can be either ACCESS_CONTROL, PROTECTION or REQUEST_RATE_LIMITING

          #Optional
          condition                  = lookup(rules.value, "condition", null)
          condition_language         = lookup(rules.value, "condition_language", null)
          is_body_inspection_enabled = lookup(rules.value, "is_body_inspection_enabled", null)
          dynamic "protection_capability_settings" {
            for_each = lookup(rules.value, "protection_capability_settings", {})
            content {
              #Optional
              allowed_http_methods           = lookup(protection_capability_settings.value, "allowed_http_methods", null)
              max_http_request_header_length = lookup(protection_capability_settings.value, "max_http_request_header_length", null)
              max_http_request_headers       = lookup(protection_capability_settings.value, "max_http_request_headers", null)
              max_number_of_arguments        = lookup(protection_capability_settings.value, "max_number_of_arguments", null)
              max_single_argument_length     = lookup(protection_capability_settings.value, "max_single_argument_length", null)
              max_total_argument_length      = lookup(protection_capability_settings.value, "max_total_argument_length", null)
            }
          }
        }
      }
    }
  }
  dynamic "request_rate_limiting" {
    for_each = lookup(each.value, "request_rate_limiting", {})
    content {
      #Optional
      dynamic "rules" {
        for_each = lookup(request_rate_limiting.value, "rules", {})
        content {
          #Required
          action_name = rules.value.action_name
          dynamic "configurations" {
            for_each = lookup(rules.value, "configurations", {})
            content {
              #Required
              period_in_seconds = configurations.value.period_in_seconds
              requests_limit    = configurations.value.requests_limit

              #Optional
              action_duration_in_seconds = lookup(configurations.value, "action_duration_in_seconds", null)
            }
          }
          name = rules.value.name
          type = rules.value.type

          #Optional
          condition          = lookup(rules.value, "condition", null)
          condition_language = lookup(rules.value, "condition_language", null)
        }
      }
    }
  }
  dynamic "response_access_control" {
    for_each = lookup(each.value, "response_access_control", {})
    content {
      #Optional
      dynamic "rules" {
        for_each = lookup(response_access_control.value, "rules", {})
        content {
          #Required
          action_name = rules.value.action_name
          name        = rules.value.name
          type        = rules.value.type

          #Optional
          condition          = lookup(rules.value, "condition", null)
          condition_language = lookup(rules.value, "condition_language", null)
        }
      }
    }
  }
  dynamic "response_protection" {
    for_each = lookup(each.value, "response_protection", {})
    content {
      #Optional
      dynamic "rules" {
        for_each = lookup(response_protection.value, "rules", {})
        content {
          #Required
          action_name = rules.value.action_name
          name        = rules.value.name
          dynamic "protection_capabilities" {
            for_each = lookup(rules.value, "protection_capabilities", {})
            #Required
            content {
              key     = protection_capabilities.key
              version = protection_capabilities.version

              #Optional
              action_name                    = lookup(protection_capabilities.value, "action_name", null)
              collaborative_action_threshold = lookup(protection_capabilities.value, "collaborative_action_threshold", null)
              dynamic "collaborative_weights" {
                for_each = lookup(protection_capabilities.value, "collaborative_weights", {})
                content {
                  #Required
                  key    = collaborative_weights.key
                  weight = collaborative_weights.value.weight
                }
              }
              dynamic "exclusions" {
                for_each = lookup(protection_capabilities.value, "exclusions", {})
                content {
                  #Optional
                  args            = lookup(exclusions.value, "args", null)
                  request_cookies = lookup(exclusion.value, "request_cookies", null)
                }
              }
            }
          }
          type = rules.value.rules_type

          #Optional
          condition                  = lookup(rules.value, "condition", null)
          condition_language         = lookup(rules.value, "condition_language", null)
          is_body_inspection_enabled = lookup(rules.value, "is_body_inspection_enabled", null)
          dynamic "protection_capability_settings" {
            for_each = lookup(rules.value, "protection_capability_settings", {})
            content {
              #Optional
              allowed_http_methods           = lookup(protection_capability_settings.value, "allowed_http_methods", null)
              max_http_request_header_length = lookup(protection_capability_settings.value, "max_http_request_header_length", null)
              max_http_request_headers       = lookup(protection_capability_settings.value, "max_http_request_headers", null)
              max_number_of_arguments        = lookup(protection_capability_settings.value, "max_number_of_arguments", null)
              max_single_argument_length     = lookup(protection_capability_settings.value, "max_single_argument_length", null)
              max_total_argument_length      = lookup(protection_capability_settings.value, "max_total_argument_length", null)
            }
          }
        }
      }
    }
  }
  system_tags = lookup(each.value, "system_tags", null)
}

data "oci_waf_protection_capabilities" "recommended_protection_capabilities" {
  #Required
  compartment_id = var.compartment_id
  #Optional
  group_tag = ["Recommended"]
}