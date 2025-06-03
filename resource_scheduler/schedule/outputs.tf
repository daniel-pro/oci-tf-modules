output "schedule_all_input_attributes" {
  description = "all input attributes of created schedules"
  value       = { for k, v in var.schedules : k => v }
}

output "schedule_all_attributes" {
  description = "all attributes of created schedules"
  value       = { for k, v in oci_resource_scheduler_schedule.schedule : k => v }
}