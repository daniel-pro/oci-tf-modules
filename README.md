# oci-tf-modules

## Breaking Changes
- **v1.0.17**: 
    - **module**: core/compute-instance
    - **description**: the `availability_domain` attribute in `oci_core_instance` variable now should be set to 1 or 2 or 3 without specifying anything else.
- **v1.0.14**: 
    - **module**: core/compute-instance
    - **description**: the `backup_policy_id` attribute in `volume_groups` or `block_volumes` variables has changed datatype, from `string` to `list` to resolve the deprecation of the `backup_policy_id` TF attribute.