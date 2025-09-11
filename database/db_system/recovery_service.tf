data "oci_recovery_protection_policies" "protection_policies" {
    #Required
    compartment_id = var.compartment_id
}

resource "oci_recovery_protection_policy" "protection_policy" {
  for_each = var.recovery_service_protection_policies

  #Required
  backup_retention_period_in_days = each.value.backup_retention_period_in_days
  compartment_id = each.value.compartment_id
  display_name = lookup(each.value, "display_name", each.key)

  #Optional
  defined_tags = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)
  must_enforce_cloud_locality = lookup(each.value, "must_enforce_cloud_locality", false)
  policy_locked_date_time = lookup(each.value, "policy_locked_date_time", null)
}