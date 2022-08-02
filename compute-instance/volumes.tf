# Copyright (c) 2018, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

#############
# Boot Volume
#############

# Assign a backup policy to instance's boot volume

resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup_policy" {
  for_each = var.boot_volumes_backup_policies 
  asset_id  = oci_core_instance.instance[each.value.instance_name].boot_volume_id
  policy_id = local.backup_policies[each.value.backup_policy]
}


resource "oci_core_volume_backup_policy_assignment" "volume_backup_policy" {
  # * The boot volume backup policy is controlled by var.boot_volume_backup_policy.
  # * You can choose between OCI default backup policies : gold, silver, bronze.
  # * If you set the variable to "disabled", no backup policy will be applied to the boot volume.
  for_each = var.volume_backup_policies
  asset_id  = oci_core_volume.volume[each.key].id
  policy_id = local.backup_policies[each.value]
}

#########
# Volume
#########
resource "oci_core_volume" "volume" {
  for_each = var.block_volumes
  availability_domain = oci_core_instance.instance[each.value.instance_name_to_attach_to].availability_domain
  compartment_id      = each.value.compartment_id
  display_name        = can(each.value.name) ? each.value.name : each.key
  size_in_gbs         = each.value.size_in_gbs
  freeform_tags = local.merged_freeform_tags
  defined_tags  = var.defined_tags
  dynamic block_volume_replicas {
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
  for_each = var.block_volumes
  attachment_type = lookup(each.value, "attachment_type", "paravirtualized")
  instance_id     = oci_core_instance.instance[each.value.instance_name_to_attach_to].id
  volume_id       = oci_core_volume.volume[each.key].id
  use_chap        = lookup(each.value,"use_chap", null)
}



### resource "oci_core_volume_group" "volume_group" {
###     for_each = var.volume_groups
###     #Required 
###     availability_domain = oci_core_instance.instance[each.value.boot_volumes_of_instances[0]].availability_domain
###     compartment_id = var.compartment_id
###     source_details {
###         #Required
###         type = "volumeIds"
###         volume_ids = [can(each.value.boot_volumes_of_instances) ? [ for i in each.value.boot_volumes_of_instances : oci_core_instance.instance[i].boot_volume_id ] : [], can(each.value.volumes) ? oci_core_volume.volume[each.value.volumes].id : [] ]
### 
###     }
### 
###     #Optional
###     backup_policy_id = data.oci_core_volume_backup_policies.test_volume_backup_policies.volume_backup_policies.0.id
###     defined_tags = {"Operations.CostCenter"= "42"}
###     display_name = var.volume_group_display_name
###     freeform_tags = {"Department"= "Finance"}
###     volume_group_replicas {
###         #Required
###         availability_domain = var.volume_group_volume_group_replicas_availability_domain
### 
###         #Optional
###         display_name = var.volume_group_volume_group_replicas_display_name
###     }
### }