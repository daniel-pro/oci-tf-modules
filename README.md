# oci-tf-modules

## Breaking Changes
- **v1.0.14**: 
    - **module**: core/compute-instance
    - **description**: the `backup_policy_id` attribute in `volume_groups` or `block_volumes` variables has changed datatype, from `string` to `list` to resolve the deprecation of the `backup_policy_id` TF attribute.