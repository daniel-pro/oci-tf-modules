resource "oci_identity_tag_namespace" "tag_namespace" {
  for_each = var.tag_namespaces
  #Required
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
  description    = each.value.description
  name           = lookup(each.value, "name", each.key)
  is_retired     = lookup(each.value, "is_retired", false)
}

resource "oci_identity_tag" "identity_tag" {
  for_each = var.identity_tags
  #Required
  description      = each.value.description
  name             = lookup(each.value, "name", each.key)
  tag_namespace_id = lookup(each.value, "tag_namespace_id", oci_identity_tag_namespace.tag_namespace[each.value.tag_namespace_name].id)

  # Optional
  is_cost_tracking = lookup(each.value, "is_cost_tracking", false)
  is_retired = lookup(each.value, "is_retired", false)  
  dynamic "validator" {
    for_each = { for key, value in each.value : key => value if key == "validator" }

    #Required
    content {
      validator_type = validator.value.validator_type
      values         = validator.value.values
    }
  }
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
}

resource "oci_identity_tag_default" "tag_default" {
  for_each = var.tag_defaults
    #Required
    compartment_id = lookup(each.value, "compartment_id", var.compartment_id)
    tag_definition_id = oci_identity_tag.identity_tag[each.value.tag_name].id
    value = each.value.value

    #Optional
    is_required = lookup(each.value, "is_required", false)

}