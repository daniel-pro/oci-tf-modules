resource "oci_identity_compartment" "identity_compartment" {
  for_each       = var.compartments
  compartment_id = lookup(each.value, "compartment_id", var.tenancy_id)
  name           = lookup(each.value, "name", each.key)
  description    = lookup(each.value, "description", each.key)
  enable_delete  = lookup(each.value, "enable_delete", false)
  freeform_tags  = lookup(each.value, "freeform_tags", null)
  defined_tags   = lookup(each.value, "defined_tags", null)
}

