resource "oci_resource_scheduler_schedule" "schedule" {
  for_each = var.schedules

  #Required
  action = each.value.action
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  recurrence_details = each.value.recurrence_details
  recurrence_type = each.value.recurrence_type

  #Optional
  defined_tags          = lookup(each.value, "defined_tags", null)
  description = lookup(each.value, "description", null)
  display_name = lookup(each.value, "name", each.key)
  freeform_tags         = lookup(each.value, "freeform_tags", null)

  dynamic "resource_filters" {
    for_each = lookup(each.value, "retention_rules", {})
    content {
      #Required
      attribute = resource_filters.value.attribute

      #Optional
      condition = lookup(resource_filters.value, "condition", null)
      should_include_child_compartments = lookup(resource_filters.value, "should_include_child_compartments", null)
      dynamic "value" {
        for_each = lookup(resource_filters.value, "state_values", {})
        content {
          #Optional
          namespace = value.value.namespace
          tag_key = value.value.tag_key
          value = value.value.value
        }
      }
    }
  }
  dynamic resources {
    for_each = lookup(each.value, "resources", {})   
      content { 
        #Required
        id = resources.value.id

        #Optional
        metadata = lookup(resources.value, "metadata", null)
      }
  }
  time_ends = lookup(each.value, "time_ends", null)
  time_starts = lookup(each.value, "time_starts", null)
}

resource "oci_identity_policy" "policy" {
  for_each = {
    for k, v in var.schedules : k => v
    if var.create_policies
  }
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

  description = "Resource Scheduler Policy for ${each.key}"
  name        = "OCI-Resource-Scheduler-Policy-for-${each.key}"
  statements  = [ "Allow any-user to manage instance in compartment id ${lookup(each.value, "compartment_id", var.compartment_id)} where all { request.principal.type='resourceschedule', request.principal.id='${oci_resource_scheduler_schedule.schedule[each.key].id}' }" ]

  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
  version_date  = lookup(each.value, "version_date", null)
}