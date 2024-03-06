resource "oci_network_load_balancer_network_load_balancer" "network_load_balancer" {
    for_each = var.network_load_balancers
    #Required
    compartment_id             = each.value.compartment_id
    display_name               = lookup(each.value, "name", each.key)
    subnet_ids                 = each.value.subnet_ids
    defined_tags               = lookup(each.value, "defined_tags", null)
    freeform_tags              = lookup(each.value, "freeform_tags", null)
    is_private                 = lookup(each.value, "is_private", "true")
    network_security_group_ids = lookup(each.value, "network_security_group_ids", null)
    is_preserve_source_destination = lookup(each.value, "is_preserve_source_destination", null)
    nlb_ip_version                 = lookup(each.value, "nlb_ip_version", null)

    dynamic "reserved_ips" {
        for_each = lookup(each.value, "reserved_ips", {})
        content {
          #Optional
          id = reserved_ips.value.ids
        }
    }    
}


resource "oci_network_load_balancer_backend_set" "backend_set" {
    for_each = { for k in flatten([
        for key, lb in var.network_load_balancers : [
          for key_bs, backend_set in lb.backend_sets : {
            lb_key      = key
            bs_key      = key_bs
            backend_set = backend_set
          }
        ]
        ]) : "${k.lb_key}_${k.bs_key}" => k
    }    

    #Required
    health_checker {
        #Required
        protocol = each.value.backend_set.health_checker.protocol # either HTTP or TCP

        #Optional
        interval_in_millis  = lookup(each.value.backend_set.health_checker, "interval_in_millis", null)
        port                = lookup(each.value.backend_set.health_checker, "port", null)
        request_data        = lookup(each.value.backend_set.health_checker, "request_data", null)
        response_body_regex = lookup(each.value.backend_set.health_checker, "response_body_regex", null)
        response_data       = lookup(each.value.backend_set.health_checker, "response_data", null)
        retries             = lookup(each.value.backend_set.health_checker, "retries", null)
        return_code         = lookup(each.value.backend_set.health_checker, "return_code", null)
        timeout_in_millis   = lookup(each.value.backend_set.health_checker, "timeout_in_millis", null)
        url_path            = lookup(each.value.backend_set.health_checker, "url_path", "/")
    }

    name                     = lookup(each.value.backend_set, "name", "${each.value.lb_key}_${each.value.bs_key}")
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.network_load_balancer[each.value.lb_key].id
    policy                   = lookup(each.value.backend_set, "policy", "ROUND_ROBIN") #  "ROUND_ROBIN" "LEAST_CONNECTIONS" "IP_HASH"

    #Optional
    ip_version         = lookup(each.value.backend_set, "ip_version", null)
    is_preserve_source = lookup(each.value.backend_set, "is_preserve_source", null)
}


resource "oci_network_load_balancer_backend" "backend" {
    for_each = { for k in flatten([
    for key, lb in var.network_load_balancers : [
        for key_bs, backend_set in lb.backend_sets : [
        for key_b, backend in backend_set.backends : {
            lb_key  = key
            bs_key  = key_bs
            b_key   = key_b
            backend = backend
        }
        ]
    ]
    ]) : "${k.lb_key}_${k.bs_key}_${k.b_key}" => k
    }

    #Required
    backendset_name          = oci_network_load_balancer_backend_set.backend_set["${each.value.lb_key}_${each.value.bs_key}"].name
    ip_address               = each.value.backend.ip_address
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.network_load_balancer[each.value.lb_key].id
    port                     = each.value.backend.port

    #Optional
    ip_address = lookup(each.value.backend, "ip_address", null)
    is_backup  = lookup(each.value.backend, "is_backup", null)
    is_drain   = lookup(each.value.backend, "is_drain", null)
    is_offline = lookup(each.value.backend, "is_offline", null)
    name       = lookup(each.value.backend, "name", null)
    target_id  = oci_cloud_guard_target.test_target.id      # TODO
    weight     = lookup(each.value.backend, "weight", null)
}

resource "oci_network_load_balancer_listener" "listener" {
    for_each = { for k in flatten([
        for key, lb in var.network_load_balancers : [
          for key_ls, listener in lb.listeners : {
            lb_key   = key
            lsnr_key = key_ls
            listener = listener
          }
        ]
        ]) : "${k.lb_key}_${k.lsnr_key}" => k
    }

    #Required
    default_backend_set_name = oci_network_load_balancer_backend_set.backend_set["${each.value.lb_key}_${each.value.listener.default_backend_set_name}"].name
    name                     = "${each.value.lb_key}_${each.value.lsnr_key}"
    network_load_balancer_id = oci_network_load_balancer_network_load_balancer.network_load_balancer[each.value.lb_key].id
    port                     = each.value.listener.port
    protocol                 = lookup(each.value.listener, "protocol", "HTTP") # "HTTP" "HTTP2" "TCP"

    #Optional
    ip_version = each.value.listener.ip_version
}
