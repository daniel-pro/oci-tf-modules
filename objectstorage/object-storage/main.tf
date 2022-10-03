
resource "oci_objectstorage_bucket" "bucket" {
  for_each = var.buckets
  #Required
  compartment_id = var.compartment_id
  name           = lookup(each.value, "name", each.key)
  namespace      = data.oci_objectstorage_namespace.namespace.namespace

  #Optional
  access_type           = lookup(each.value, "access_type", "NoPublicAccess")
  auto_tiering          = lookup(each.value, "auto_tiering", "Disabled")
  defined_tags          = lookup(each.value, "defined_tags", null)
  freeform_tags         = lookup(each.value, "freeform_tags", null)
  kms_key_id            = lookup(each.value, "kms_key_id", null)
  metadata              = lookup(each.value, "metadata", null)
  object_events_enabled = lookup(each.value, "object_events_enabled", "false")
  storage_tier          = lookup(each.value, "storage_tier", "Standard")

  dynamic "retention_rules" {
    for_each = lookup(each.value, "retention_rules", {})
    content {
      display_name = retention_rules.value.display_name
      duration {
        #Required
        time_amount = retention_rules.value.duration_time_amount
        time_unit   = retention_rules.value.duration_time_unit
      }
      time_rule_locked = retention_rules.value.time_rule_locked
    }
  }
  versioning = lookup(each.value, "bucket_versioning", "Disabled")
}

data "oci_objectstorage_namespace" "namespace" {

  #Optional
  compartment_id = var.compartment_id
}