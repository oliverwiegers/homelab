terraform {
  required_version = ">= 1.6.0"

  required_providers {
    openwrt = {
      source = "Foxboron/openwrt"
      version = ">= 0.0.2"
    }
  }
}
