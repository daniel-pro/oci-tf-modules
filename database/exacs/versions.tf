terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      #version = ">=4.86.0"
      version = "7.21.0"

    }
  }
  required_version = ">= 1.2.4"
}
