locals {
  is_flex_shape     = (var.instance_shape == "VM.Standard.E4.Flex") || (var.instance_shape == "VM.Standard.E3.Flex")
  flex_shape_config = local.is_flex_shape ? [{ "ocpus" : var.ocpus, "memory_in_gbs" : var.memory_in_gbs, "baseline_ocpu_utilization": try(var.baseline_ocpu_utilization, null) }] : []
  default_backup_policies = { for i in data.oci_core_volume_backup_policies.default_backup_policies.volume_backup_policies : i.display_name => i.id }
}

data "oci_core_volume_backup_policies" "default_backup_policies" {}

data "cloudinit_config" "oas_cloud_init" {
  gzip          = "true"
  base64_encode = "true"

  part {
    filename     = "oas-cloud-init.cfg"
    content_type = "text/cloud-config"
    content      = templatefile( "${path.module}/cloud_init/cloudinit.template.yaml", 
    { 
      generate_biconfig_content = base64gzip(file("${path.module}/templates/generate_biconfig.sh"))
      admin_user_name =    var.admin_user_name
      admin_password = var.admin_password
      connect_string = var.connect_string    
      new_db_admin_username = var.new_db_admin_username
      new_db_password = var.new_db_password
      oas_rcu_schema_prefix = var.oas_rcu_schema_prefix
      oas_rcu_schema_password = var.oas_rcu_schema_password
      create_domain = var.create_domain
      firewallportsconfig_content = base64gzip(file("${path.module}/templates/DefaultSingleNodeOASFirewallPorts.xml"))
      firewallportsscript_content = base64gzip(file("${path.module}/templates/open_oas_firewall_ports.sh"))
      createdomainscript_content = base64gzip(file("${path.module}/templates/create_oas_domain.sh"))
      installerscript_content = var.create_domain ? base64gzip(file("${path.module}/templates/oas_installer.sh")) : base64gzip(file("${path.module}/templates/skip_oas_installer.sh"))
      biconfigcleaner_content = base64gzip(file("${path.module}/templates/biconfigcleaner.sh"))
      createDataPartition_content = base64gzip(file("${path.module}/templates/createDataPartition.sh"))
    })
  }
}

resource "oci_core_instance" "OAS_MP_instance" {
  availability_domain = var.availability_domain

  compartment_id = var.compartment_id

  shape = var.instance_shape
  source_details {
    source_id               = var.mp_OAS_listing_image_resource_id
    source_type             = "image"
    boot_volume_size_in_gbs = var.boot_volume_size
  }

  dynamic "shape_config" {
    for_each = local.flex_shape_config
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
      baseline_ocpu_utilization = shape_config.value.baseline_ocpu_utilization
    }
  }
  display_name = var.instance_display_name

  create_vnic_details {
    assign_public_ip = var.assign_public_ip
    subnet_id        = var.subnet_id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = data.cloudinit_config.oas_cloud_init.rendered
  }

  preserve_boot_volume = false

}

# Assign a backup policy to instance's boot volume

resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup_policy" {
  count = can(var.boot_backup_policy) ? 1 : 0  
  asset_id  = oci_core_instance.OAS_MP_instance.boot_volume_id
  policy_id = length(regexall("gold|silver|bronze", var.boot_backup_policy)) > 0 ? local.default_backup_policies[var.boot_backup_policy] : var.boot_backup_policy
}

output "vm_public_ip" {
  value = oci_core_instance.OAS_MP_instance.public_ip
}
output "vm_private_ip" {
  value = oci_core_instance.OAS_MP_instance.private_ip
}
