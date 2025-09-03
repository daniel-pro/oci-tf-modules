terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=6.17.0"
    }
  }
  required_version = ">= 1.10.0"
}
