data "oci_core_volume_backup_policies" "default_backup_policies" {}

data "oci_core_volume_backup_policies" "volume_backup_policies" {
  compartment_id = var.compartment_id
}

locals {
  ADs                     = (data.oci_identity_availability_domains.ad.availability_domains != null) ? [for i in data.oci_identity_availability_domains.ad.availability_domains : i.name] : ["dummy-ad-useful-only-to-avoid-errors-with-terragrunt-during-plan-phase"]
  default_backup_policies = { for i in data.oci_core_volume_backup_policies.default_backup_policies.volume_backup_policies : i.display_name => i.id }
}

#############
# Boot Volume
#############




# Assign a backup policy to instance's boot volume

resource "oci_core_volume_backup_policy_assignment" "boot_volume_backup_policy" {
  for_each  = var.boot_volumes_backup_policy_assignments
  asset_id  = oci_core_instance.instance[each.value.instance_name].boot_volume_id
  policy_id = length(regexall("gold|silver|bronze", each.value.backup_policy)) > 0 ? local.default_backup_policies[each.value.backup_policy] : each.value.backup_policy
}


resource "oci_core_volume_backup_policy_assignment" "volume_backup_policy" {
  # * The boot volume backup policy is controlled by var.boot_volume_backup_policy.
  # * You can choose between OCI default backup policies : gold, silver, bronze.
  # * If you set the variable to "disabled", no backup policy will be applied to the boot volume.
  for_each  = var.volume_backup_policy_assignments
  asset_id  = oci_core_volume.volume[each.key].id
  policy_id = length(regexall("gold|silver|bronze", each.value)) > 0 ? local.default_backup_policies[each.value] : each.value
}

#########
# Volume
#########
resource "oci_core_volume" "volume" {
  for_each            = var.block_volumes
  availability_domain = data.oci_identity_availability_domains.ad.availability_domains[each.value.availability_domain - 1].name
  compartment_id      = lookup(each.value, "compartment_id", var.compartment_id)
  display_name        = lookup(each.value, "name", each.key)
  size_in_gbs         = each.value.size_in_gbs
  freeform_tags       = lookup(each.value, "freeform_tags", null)
  defined_tags        = lookup(each.value, "defined_tags", null)
  vpus_per_gb         = lookup(each.value, "vpus_per_gb", null)
  
  dynamic "autotune_policies" {
    for_each = { for key, value in each.value : key => value if key == "autotune_policies" }
    content {
        #Required
        autotune_type   = autotune_policies.value.autotune_type

        #Optional
        max_vpus_per_gb = autotune_policies.value.max_vpus_per_gb
    }
  }
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
#  for_each  = var.block_volumes
  for_each = { for k in flatten([
    for key, bv in var.block_volumes : [
      for instance_name in (can(bv.instance_names_to_attach_to) ? bv.instance_names_to_attach_to : [] ) : {
        bv_key                     = key
        instance_name_to_attach_to = instance_name
        block_volume               = bv
      }
    ]
    ]) : "${k.bv_key}_${k.instance_name_to_attach_to}" => k
  }
  attachment_type = lookup(each.value, "attachment_type", "paravirtualized")
  instance_id     = oci_core_instance.instance[each.value.instance_name_to_attach_to].id
  volume_id       = oci_core_volume.volume[each.value.bv_key].id
  use_chap        = lookup(each.value.block_volume, "use_chap", null)

  #Optional
  device = lookup(each.value.block_volume, "device", null)
  display_name =  lookup(each.value.block_volume, "display_name", each.key)
  encryption_in_transit_type = lookup(each.value.block_volume, "encryption_in_transit_type", null)
  is_agent_auto_iscsi_login_enabled = lookup(each.value.block_volume, "is_agent_auto_iscsi_login_enabled", null)
  is_pv_encryption_in_transit_enabled = lookup(each.value.block_volume, "is_pv_encryption_in_transit_enabled", null)
  is_read_only = lookup(each.value.block_volume, "is_read_only", null)
  is_shareable = lookup(each.value.block_volume, "is_shareable", null)

}

resource "oci_core_volume_backup_policy_assignment" "vg_volume_backup_policy_assignment" {
  for_each = { for k in flatten([
    for key, vg in var.volume_groups : [
      for key_bp, volume_group in (can(vg.backup_policy_id) ? vg.backup_policy_id : [] ) : {
        vg_key       = key
        bp_key       = vg.backup_policy_id[key_bp]
      }
    ]
    ]) : "${k.vg_key}_${k.bp_key}" => k
  }
  #Required
  asset_id = oci_core_volume_group.volume_group[each.value.vg_key].id
  policy_id = each.value.bp_key
}


resource "oci_core_volume_backup_policy_assignment" "vol_volume_backup_policy_assignment" {
  for_each = { for k in flatten([
    for key, vol in var.block_volumes : [
      for key_bp, block_volume in (can(vol.backup_policy_id) ? vol.backup_policy_id : []) : {
        vol_key      = key
        bp_key       = vol.backup_policy_id[key_bp]
      }
    ]
    ]) : "${k.vol_key}_${k.bp_key}" => k
  }
  #Required
  asset_id = oci_core_volume.volume[each.value.vol_key].id
  policy_id = each.value.bp_key
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
#  backup_policy_id = lookup(each.value, "backup_policy_id", null)
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