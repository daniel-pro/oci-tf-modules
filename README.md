# oci-tf-modules
## New Features
- **v1.0.29**: 
    - **module**: resource_scheduler/schedule
    - **description**: module to manage the resource scehduler.
    
## Breaking Changes
- **v1.0.26**: 
    - **module**: database/db_system
    - **description**: the `availability_domain` attribute in `oci_database_db_system` variable now should be set to 1 or 2 or 3 without specifying anything else.
    - **module**: database/exacs
    - **description**: the `availability_domain` attribute in `oci_database_cloud_exadata_infrastructure` variable now should be set to 1 or 2 or 3 without specifying anything else.
- **v1.0.24**: 
    - **module**: load_balancer/load-balancer
    - **description**: the `routing_policy` attribute in `load_balancers` variable has been introduced and now it's mandatory. In case it's not needed it can be defined empty, like this: `routing_policy = {}`
- **v1.0.21**: 
    - **module**: load_balancer/load-balancer
    - **description**: the `items` attribute in `load_balancer_rule_set` variable has been introduced and has replaced the items_* attributes, so that we can handle multiple items in the same rule_set.
- **v1.0.18**: 
    - **module**: core/compute-instance
    - **description**: the `instance_name_to_attach_to` attribute in `oci_core_volume_attachment` variable has changed name - `instance_names_to_attach_to` - and datatype, from `string` to `list` to permit multiple volume attachments, so shared block volumes.
- **v1.0.17**: 
    - **module**: core/compute-instance
    - **description**: the `availability_domain` attribute in `oci_core_instance` variable now should be set to 1 or 2 or 3 without specifying anything else.
- **v1.0.14**: 
    - **module**: core/compute-instance
    - **description**: the `backup_policy_id` attribute in `volume_groups` or `block_volumes` variables has changed datatype, from `string` to `list` to resolve the deprecation of the `backup_policy_id` TF attribute.
