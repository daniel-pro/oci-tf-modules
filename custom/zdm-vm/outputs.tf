output "private_ip" {
  description = "ZDM VM private IP"
  value       = oci_core_instance.zdminstance.*.private_ip
}
