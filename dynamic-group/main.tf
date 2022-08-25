resource "oci_identity_dynamic_group" "dynamic_group" {

  for_each = var.dynamic_groups

  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  name           = lookup(each.value, "name", each.key)
  description    = lookup(each.value, "description", each.key)
  matching_rule  = each.value.matching_rule

  defined_tags   = lookup(each.value, "defined_tags", null)
  freeform_tags  = lookup(each.value, "freeform_tags", null)

}
