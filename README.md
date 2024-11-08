# oci-tf-modules

## Breaking Changes
- **v1.0.18**: 
    - **module**: core/compute-instance
    - **description**: the `instance_name_to_attach_to` attribute in `oci_core_volume_attachment` variable has changed name - `instance_names_to_attach_to` - and datatype, from `string` to `list` to permit multiple volume attachments, so shared block volumes.
- **v1.0.17**: 
    - **module**: core/compute-instance
    - **description**: the `availability_domain` attribute in `oci_core_instance` variable now should be set to 1 or 2 or 3 without specifying anything else.
- **v1.0.14**: 
    - **module**: core/compute-instance
    - **description**: the `backup_policy_id` attribute in `volume_groups` or `block_volumes` variables has changed datatype, from `string` to `list` to resolve the deprecation of the `backup_policy_id` TF attribute.
