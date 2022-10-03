output "log_group_all_input_attributes" {
  description = "all input attributes of created log groups"
  value       = { for k, v in var.log_groups : k => v }
}

output "log_group_all_attributes" {
  description = "all attributes of created log groups"
  value       = { for k, v in oci_logging_log_group.log_group : k => v }
}

output "log_all_input_attributes" {
  description = "all input attributes of created logs"
  value       = { for k, v in var.logs : k => v }
}

output "log_all_attributes" {
  description = "all attributes of created logs"
  value       = { for k, v in oci_logging_log.log : k => v }
}

output "unified_agent_configuration_all_input_attributes" {
  description = "all input attributes of created unified agent configurations"
  value       = { for k, v in var.unified_agent_configurations : k => v }
}

output "unified_agent_configuration_all_attributes" {
  description = "all attributes of unified agent configurations"
  value       = { for k, v in oci_logging_unified_agent_configuration.unified_agent_configuration : k => v }
}