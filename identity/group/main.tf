resource "oci_identity_group" "identity_group" {
  for_each       = var.groups
  compartment_id = lookup(each.value, "compartment_id", var.tenancy_id)
  name           = lookup(each.value, "name", each.key)
  description    = lookup(each.value, "description", each.key)
  freeform_tags  = lookup(each.value, "freeform_tags", null)
  defined_tags   = lookup(each.value, "defined_tags", null)
}

