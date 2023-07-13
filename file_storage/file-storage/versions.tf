terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=5.4.0"
    }
  }
  required_version = ">= 1.2.4"
}
