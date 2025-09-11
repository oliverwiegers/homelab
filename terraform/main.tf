locals {
  server_dns_a_records = {
    for domain, settings in {
      for server, properties in local.live_hosts : "${split(".", server)[1]}.${split(".", server)[2]}" => {
        records = [
          {
            type    = "A"
            subname = split(".", server)[0]
            records = [properties.ipv4]
          },
        ]
      }...
    } : domain => { records = flatten([settings[*].records]) }
  }

  merged_dns_records = {
    for domain, settings in var.domains : domain => {
      records = concat(settings.records, try(local.server_dns_a_records[domain].records, []))
    }
  }

  domain = one(compact([for domain, properties in var.domains : properties.type == "external" ? domain : null]))

  # Will move to hetzner soon.
  netcup_hosts = {
    kryha = {
      hostName    = "kryha.oliverwiegers.com"
      hostId      = "4838d7d7"
      primaryIPv4 = "152.53.49.50"
      colocation  = "netcup"
    }
  }

  homelab_json = {
    domain         = local.domain
    internalDomain = try(one(compact([for domain, properties in var.domains : properties.type == "internal" ? domain : null])), local.domain)
    homeDomain     = "oliverwiegers.net"

    acme = {
      dnsProvider = var.dns.provider
      dnsResolver = var.dns.resolver
    }

    hosts = merge({
      for server, properties in local.live_hosts : split(".", server)[0] => {
        hostName    = server
        hostId      = properties.host_id
        primaryIPv4 = properties.ipv4
        colocation  = "hetzner"
      }
    }, local.netcup_hosts)
  }

  nixos_hosts = {
    for server, properties in module.servers : server => {
      hostname    = properties.hostname
      instance_id = properties.host_id
    } if var.servers[server].bootstrap_nixos
  }
}

data "sops_file" "secrets" {
  source_file = "${path.root}/secrets.yaml"
}

module "registrar_config" {
  source = "${path.root}/modules/registrar_config"

  domain_admin = {
    name         = data.sops_file.secrets.data["domain_admin.name"]
    address      = data.sops_file.secrets.data["domain_admin.address"]
    city         = data.sops_file.secrets.data["domain_admin.city"]
    postal_code  = data.sops_file.secrets.data["domain_admin.postal_code"]
    country_code = data.sops_file.secrets.data["domain_admin.country_code"]
    phone_number = data.sops_file.secrets.data["domain_admin.phone_number"]
    email        = data.sops_file.secrets.data["domain_admin.email"]
  }

  domains = {
    for domain, properties in var.domains : domain => {
      extra_data  = properties.extra_data
      nameservers = properties.nameservers
    }
  }
}

module "dns" {
  source = "${path.root}/modules/dns"

  domains = local.merged_dns_records

  depends_on = [module.registrar_config]
}

resource "local_file" "homelab_json" {
  content         = jsonencode(local.homelab_json)
  filename        = "${path.root}/../nix/.homelab.json"
  file_permission = "0660"
}

module "bootstrap_nixos" {
  source = "${path.root}/modules/bootstrap_nixos"

  for_each = local.nixos_hosts

  host        = each.key
  hostname    = each.value.hostname
  instance_id = each.value.instance_id
}

module "router" {
  source = "${path.root}/modules/router"
}
