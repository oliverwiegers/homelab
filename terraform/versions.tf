terraform {
  required_version = ">= 1.6.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.50.0"
    }

    desec = {
      source  = "Valodim/desec"
      version = ">= 0.5.0"
    }

    inwx = {
      source  = "inwx/inwx"
      version = ">= 1.6.0"
    }

    minio = {
      source  = "aminueza/minio"
      version = ">= 3.5.2"
    }

    sops = {
      source  = "carlpett/sops"
      version = ">= 1.2.0"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.3"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }

    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }

    openwrt = {
      source = "Foxboron/openwrt"
      version = ">= 0.0.2"
    }
  }
}
