# data "oci_identity_availability_domains" "ad" {
#   compartment_id = var.compartment_id
# }

resource "oci_recovery_recovery_service_subnet" "recovery_service_subnet" {
  for_each = var.subnets

  #Required
  compartment_id = each.value.compartment_id
  display_name   = lookup(each.value, "display_name", each.key)
  vcn_id         = each.value.vcn_id

  #Optional
  defined_tags = lookup(each.value, "defined_tags", null)
  freeform_tags = lookup(each.value, "freeform_tags", null)
  nsg_ids = lookup(each.value, "nsg_ids", null)
  subnets = lookup(each.value, "subnets", null)
}

resource "oci_recovery_protection_policy" "protection_policy" {
  for_each = var.protection_policies

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