data "oci_core_volume_backup_policies" "default_backup_policies" {}

data "oci_core_volume_backup_policies" "volume_backup_policies" {
  compartment_id = var.compartment_id  
}

locals {
  ADs = (data.oci_identity_availability_domains.ad.availability_domains != null) ? [for i in data.oci_identity_availability_domains.ad.availability_domains : i.name] : ["dummy-ad-useful-only-to-avoid-errors-with-terragrunt-during-plan-phase"]
  backup_policies = merge({
    // Iterate through data.oci_core_volume_backup_policies.default_backup_policies and create a map containing name & ocid
    // This is used to specify a backup policy id by name
    for i in data.oci_core_volume_backup_policies.volume_backup_policies.volume_backup_policies : i.display_name => i.id 
  },
  {
    for i in data.oci_core_volume_backup_policies.default_backup_policies.volume_backup_policies : i.display_name => i.id 
  }
  )
}

#############
# Boot Volume
#############




# Assign a backup policy to instance's boot volume

resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup_policy" {
  for_each  = var.boot_volumes_backup_policy_assignments
  asset_id  = oci_core_instance.instance[each.value.instance_name].boot_volume_id
  policy_id = local.backup_policies[each.value.backup_policy]
}


resource "oci_core_volume_backup_policy_assignment" "volume_backup_policy" {
  # * The boot volume backup policy is controlled by var.boot_volume_backup_policy.
  # * You can choose between OCI default backup policies : gold, silver, bronze.
  # * If you set the variable to "disabled", no backup policy will be applied to the boot volume.
  for_each  = var.volume_backup_policy_assignments
  asset_id  = oci_core_volume.volume[each.key].id
  policy_id = each.value
}

#########
# Volume
#########
resource "oci_core_volume" "volume" {
  for_each            = var.block_volumes
  availability_domain = oci_core_instance.instance[each.value.instance_name_to_attach_to].availability_domain
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  display_name        = lookup(each.value, "name", each.key)
  size_in_gbs         = each.value.size_in_gbs
  freeform_tags       = lookup(each.value, "freeform_tags", null)
  defined_tags        = lookup(each.value, "defined_tags", null)
  dynamic "block_volume_replicas" {
    for_each = can(each.value.replicas) ? each.value.replicas : {}
    content {
      #Required
      availability_domain = block_volume_replicas.value.destinaton_availability_domain

      #Optional
      display_name = lookup(block_volume_replicas.value, "name", block_volume_replicas.key)
    }
  }
}

####################
# Volume Attachment
####################
resource "oci_core_volume_attachment" "volume_attachment" {
  for_each        = var.block_volumes
  attachment_type = lookup(each.value, "attachment_type", "paravirtualized")
  instance_id     = oci_core_instance.instance[each.value.instance_name_to_attach_to].id
  volume_id       = oci_core_volume.volume[each.key].id
  use_chap        = lookup(each.value, "use_chap", null)
}



resource "oci_core_volume_group" "volume_group" {
  for_each = var.volume_groups
  #Required 
  availability_domain = (can(each.value.boot_volumes_of_instances) ? oci_core_instance.instance[each.value.boot_volumes_of_instances[0]].availability_domain : can(each.value.volumes) ? oci_core_volume.volume[each.value.volumes[0]].id : null)
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  source_details {
    #Required
    type       = "volumeIds"
    volume_ids = concat((can(each.value.boot_volumes_of_instances) ? [for i in each.value.boot_volumes_of_instances : oci_core_instance.instance[i].boot_volume_id] : []), can(each.value.volumes) ? [for i in each.value.volumes : oci_core_volume.volume[i].id] : [])
  }

  #Optional
  backup_policy_id = can(each.value.backup_policy) ? local.backup_policies[each.value.backup_policy] : null
  freeform_tags    = lookup(each.value, "freeform_tags", null)
  defined_tags     = lookup(each.value, "defined_tags", null)
  display_name     = lookup(each.value, "name", each.key)
  dynamic "volume_group_replicas" {
    for_each = { for key, value in each.value : key => value if key == "volume_group_replicas" }
    content {
      #Required
      availability_domain = volume_group_replicas.value.availability_domain

      #Optional
      display_name = lookup(volume_group_replicas.value, "name", null)
    }
  }
}