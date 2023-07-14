data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

data "oci_file_storage_snapshot" "snapshot" {
  for_each    = var.snapshots
  snapshot_id = each.value.snap_id
}

resource "oci_file_storage_file_system" "file_system" {
  for_each = var.file_systems

  availability_domain = each.value.availability_domain
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  display_name        = lookup(each.value, "name", each.key)

  filesystem_snapshot_policy_id = can(each.value.filesystem_snapshot_policy) ? oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy[each.value.filesystem_snapshot_policy].id : null
  kms_key_id                    = can(each.value.kms_key_id) ? each.value.kms_key.id : null
  source_snapshot_id            = can(each.value.source_snapshot) ? data.oci_file_storage_snapshot.snapshot[each.value.source_snapshot].id : null

  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
}

resource "oci_file_storage_mount_target" "mount_target" {
  for_each = var.mount_targets
  #Required
  availability_domain = each.value.availability_domain
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  subnet_id           = each.value.subnet_id

  #Optional
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
  display_name  = lookup(each.value, "name", each.key)

  hostname_label = lookup(each.value, "hostname_label", null)
  ip_address     = lookup(each.value, "ip_address", null)
  nsg_ids        = lookup(each.value, "nsg_ids", null)
}

resource "oci_file_storage_filesystem_snapshot_policy" "filesystem_snapshot_policy" {
  for_each = var.snapshot_policies
  #Required
  availability_domain = each.value.availability_domain
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)

  #Optional
  freeform_tags = lookup(each.value, "freeform_tags", null)
  defined_tags  = lookup(each.value, "defined_tags", null)
  display_name  = lookup(each.value, "name", each.key)

  policy_prefix = lookup(each.value, "policy_prefix", null)

  dynamic "schedules" {
    for_each = lookup(each.value, "schedules", {})
    content {
      #Required
      period    = schedules.value.period
      time_zone = schedules.value.time_zone

      #Optional
      day_of_month                  = lookup(schedules.value, "day_of_month", null)
      day_of_week                   = lookup(schedules.value, "day_of_week", null)
      hour_of_day                   = lookup(schedules.value, "hour_of_day", null)
      month                         = lookup(schedules.value, "month", null)
      retention_duration_in_seconds = lookup(schedules.value, "retention_duration_in_seconds", null)
      schedule_prefix               = lookup(schedules.value, "schedule_prefix", null)
      time_schedule_start           = lookup(schedules.value, "time_schedule_start", null)
    }
  }
}

resource "oci_file_storage_export_set" "export_set" {
  for_each = var.mount_targets

  #Required
  mount_target_id = oci_file_storage_mount_target.mount_target[each.key].id

  #Optional
  display_name      = lookup(each.value, "export_set_name", each.key)
  max_fs_stat_bytes = lookup(each.value, "export_set_max_fs_stat_bytes", null)
  max_fs_stat_files = lookup(each.value, "export_set_max_fs_stat_files", null)
}

resource "oci_file_storage_export" "export" {
  for_each = { for k in flatten([
    for key, item in var.file_systems : [
      for subitem_key, subitem in lookup(item, "exports", {}) : {
        file_system_key = key
        file_system     = item
        export_key      = subitem_key
        export          = subitem
      }
    ]
    ]) : "${k.file_system_key}_${k.export_key}" => k
  }
  #Required
  export_set_id  = oci_file_storage_export_set.export_set[each.value.export.mount_target].id
  file_system_id = oci_file_storage_file_system.file_system[each.value.file_system_key].id
  path           = each.value.export.path

  #Optional
  dynamic "export_options" {
    for_each = lookup(each.value.export, "export_options", {})
    content {
      #Required
      source = export_options.value.source

      #Optional
      access                         = lookup(export_options.value, "access", null)
      anonymous_gid                  = lookup(export_options.value, "anonymous_gid", null)
      anonymous_uid                  = lookup(export_options.value, "anonymous_uid", null)
      identity_squash                = lookup(export_options.value, "identity_squash", null)
      require_privileged_source_port = lookup(export_options.value, "require_privileged_source_port", null)
    }
  }
}

resource "oci_file_storage_snapshot" "snapshot" {
  for_each = var.snapshots
  #Required
  file_system_id = oci_file_storage_file_system.file_system[each.value.file_system].id
  name           = lookup(each.value, "name", each.key)

  #Optional
  expiration_time = lookup(each.value, "expiration_time", null)
  freeform_tags   = lookup(each.value, "freeform_tags", null)
  defined_tags    = lookup(each.value, "defined_tags", null)
}