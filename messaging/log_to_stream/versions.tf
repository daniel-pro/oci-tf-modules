terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=6.5.0"
    }
  }
  required_version = ">= 1.2.4"
}
