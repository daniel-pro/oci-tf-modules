resource "oci_core_volume_backup_policy" "volume_backup_policy" {
  for_each = var.volume_backup_policies
  #Required
  compartment_id = lookup(each.value, "compartment_id", var.compartment_id)

  #Optional
  destination_region = lookup(each.value, "destination_region", null)
  freeform_tags      = lookup(each.value, "freeform_tags", null)
  defined_tags       = lookup(each.value, "defined_tags", null)
  display_name       = lookup(each.value, "name", each.key)

  dynamic "schedules" {
    for_each = lookup(each.value, "schedules", {})
    content {
      #Required
      backup_type       = schedules.value.backup_type # Either FULL or INCREMENTAL
      period            = schedules.value.period      #Either ONE_DAY or ONE_WEEK or ONE_MONTH or ONE_YEAR
      retention_seconds = schedules.value.retention_seconds

      #Optional
      day_of_month   = lookup(schedules.value, "day_of_month", null)
      day_of_week    = lookup(schedules.value, "day_of_week", null)
      hour_of_day    = lookup(schedules.value, "hour_of_day", null)
      month          = lookup(schedules.value, "month", null)
      offset_seconds = lookup(schedules.value, "offset_seconds", null)
      offset_type    = lookup(schedules.value, "offset_type", null) # hourOfDay or dayOfWeek or dayOfMonth
      time_zone      = lookup(schedules.value, "time_zone", null)   # UTC or REGIONAL_DATA_CENTER_TIME
    }
  }
}