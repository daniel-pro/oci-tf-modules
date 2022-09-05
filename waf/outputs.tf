output "web_app_firewall_all_attributes" {
  description = "all attributes of created compute web app firewalls"
  value       = { for k, v in oci_waf_web_app_firewall.web_app_firewall : k => v }
}

output "web_app_firewall_all_input_attributes" {
  description = "all input attributes of created web app firewalls"
  value       = { for k, v in var.web_app_firewalls : k => v }
}

output "web_app_firewall_policy_all_attributes" {
  description = "all attributes of created compute web app firewalls"
  value       = { for k, v in oci_waf_web_app_firewall_policy.web_app_firewall_policy : k => v }
}

output "web_app_firewall_policy_all_input_attributes" {
  description = "all input attributes of created web app firewalls"
  value       = { for k, v in var.web_app_firewall_policies : k => v }
}