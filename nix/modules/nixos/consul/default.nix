{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.consul;
  caCert = "${cfg.domain}-agent-ca.pem";
  caKey = "${cfg.domain}-agent-ca-key.pem";
  serverCert = "${cfg.datacenter}-server-${cfg.domain}-0.pem";
  serverKey = "${cfg.datacenter}-server-${cfg.domain}-0-key.pem";
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.consul = {
    enable = lib.mkEnableOption "Consul agent or server.";

    type = lib.mkOption {
      description = "Type of consul instance. Must be one of [ \"client\" \"server\" ].";
      type = lib.types.enum [
        "client"
        "server"
      ];
      default = "client";
      defaultText = "consul.type = \"client\";";
      example = "consul.type = \"server\";";
    };

    clientSecretsFile = lib.mkOption {
      description = "Path to secrets.yaml for nix-sops containing client secrets.";
      type = lib.types.path;
      default = null;
      defaultText = "consul.secretsFile = null;";
      example = "consul.secretsFile = ./secrets/foo.yaml;";
    };

    serverSecretsFile = lib.mkOption {
      description = "Path to secrets.yaml for nix-sops containing server secrets.";
      type = lib.types.path;
      default = null;
      defaultText = "consul.secretsFile = ./secrets.yaml;";
      example = "consul.secretsFile = ./secrets/foo.yaml;";
    };

    domain = lib.mkOption {
      description = "Custom domain to resolve for DNS.";
      type = lib.types.str;
      default = null;
      defaultText = "consul.domain = null";
      example = "consul.domain = \"example.com\"";
    };

    datacenter = lib.mkOption {
      description = "Datacenter name for consul.";
      type = lib.types.str;
      default = "dc1";
      defaultText = "consul.datacenter = \"dc1\"";
      example = "consul.datacenter = \"dc2\"";
    };

    serverNodeCount = lib.mkOption {
      description = "Number of server nodes in consul cluster.";
      type = lib.types.int;
      default = 3;
      defaultText = "consul.serverNodeCount = 3";
      example = "consul.serverNodeCount = 1";
    };

    serverClusterMembers = lib.mkOption {
      description = "List or IPs of server nodes additional to the present one. Only take effect on server nodes.";
      type = lib.types.listOf lib.types.str;
      default = [ ];
      defaultText = "consul.serverClusterMembers = []";
      example = "consul.serverClusterMembers = [ \"172.25.25.245\" ]";
    };

    bindAddr = lib.mkOption {
      description = "Address to bind consul server to. Only takes effect on server nodes.";
      type = lib.types.str;
      default = null;
      defaultText = "consul.bindAddr = null";
      example = "consul.bindAddr = \"100.100.100.100\".";
    };

    uiBindAddr = lib.mkOption {
      description = "Address to bind consul UI to. Only takes effect on server nodes.";
      type = lib.types.str;
      default = "localhost";
      defaultText = "consul.uiBindAddr = \"localhost\"";
      example = "consul.uiBindAddr = \"100.100.100.100\"";
    };
  };

  config = lib.mkIf cfg.enable {
    # Setting consul user and group manually here.
    # So the user is available at first deployment to set secret owner for sops secrets.
    users = {
      users.consul = {
        description = "Consul agent daemon user";
        isSystemUser = true;
        group = "consul";
        # The shell is needed for health checks
        shell = "/run/current-system/sw/bin/bash";
      };

      groups.consul = { };
    };

    systemd.services = {
      consul-setup = lib.mkIf (cfg.type == "server") {
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [ config.services.consul.package ];

        script = ''
          if ! [ -d /etc/consul.d/certs ]; then
            mkdir -p /etc/consul.d/certs
            chown -R consul:consul /etc/consul.d/
          fi

          if ! [ -f /etc/consul.d/certs/${serverCert} ]; then
            consul tls cert create \
              -server \
              -dc ${cfg.datacenter} \
              -domain ${cfg.domain} \
              -ca $CREDENTIALS_DIRECTORY/ca \
              -key $CREDENTIALS_DIRECTORY/key

            install -m 0400 -o consul -g consul ${serverCert} /etc/consul.d/certs/
            install -m 0400 -o consul -g consul ${serverKey} /etc/consul.d/certs/

            rm ${serverCert} ${serverKey}
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          Restart = "no";
          LoadCredential = [
            "ca:${config.sops.secrets."consul/${caCert}".path}"
            "key:${config.sops.secrets."consul/${caKey}".path}"
          ];
        };
      };

      consul = lib.mkIf (cfg.type == "server") {
        wants = [
          "consul-setup.service"
          "tailscaled.service"
        ];
        after = [
          "consul-setup.service"
          "tailscaled.service"
        ];
      };
    };

    services = {
      #nginx = {
      #  enable = true;

      #  upstreams = {
      #    consul-ui.servers = {
      #      "localhost:8500" = {};
      #    };
      #  };

      #  # Consul UI right now can't be exposed on IPs other than 127.0.0.1.
      #  # So we expose a specific vHost on the wanted IP.
      #  virtualHosts = {
      #    "consul-ui" = {
      #      locations."/" = {
      #        proxyPass = "http://consul-ui";
      #        proxyWebsockets = true;
      #      };

      #      listen = [
      #        {
      #          addr = cfg.uiBindAddr;
      #          port = 8500;
      #        }
      #      ];
      #    };
      #  };
      #};

      consul = {
        enable = true;
        webUi = lib.mkIf (cfg.type == "server") true;
        extraConfigFiles = [ config.sops.templates."gossip.json".path ];

        interface = {
          bind = "tailscale0";
          advertise = "tailscale0";
        };

        extraConfig = {
          inherit (cfg) datacenter domain;

          server = lib.mkIf (cfg.type == "server") true;
          bootstrap_expect = lib.mkIf (cfg.type == "server") cfg.serverNodeCount;
          retry_join = [ "100.64.0.3" ];
          # bind_addr = lib.mkIf (cfg.type == "server") cfg.bindAddr;

          tls = {
            defaults = {
              ca_file = config.sops.secrets."consul/${caCert}".path;
              cert_file = lib.mkIf (cfg.type == "server") "/etc/consul.d/certs/${serverCert}";
              key_file = lib.mkIf (cfg.type == "server") "/etc/consul.d/certs/${serverKey}";
              verify_incoming = true;
              verify_outgoing = true;
            };

            internal_rpc = {
              verify_server_hostname = true;
            };
          };

          auto_encrypt = {
            allow_tls = lib.mkIf (cfg.type == "server") true;
            tls = lib.mkIf (cfg.type == "client") true;
          };

          # Service mesh.
          connect = {
            enabled = true;
          };
        };
      };
    };

    sops =
      let
        consulOpts = {
          owner = "consul";
          mode = "0440";
          restartUnits = [ "consul-setup.service" ];
          reloadUnits = [ "consul.service" ];
        };
      in
      {
        secrets = lib.mkMerge [
          {
            "consul/${caCert}" = {
              sopsFile = cfg.clientSecretsFile;
            } // consulOpts;

            "consul/gossip" = {
              sopsFile = cfg.clientSecretsFile;
            } // consulOpts;
          }

          (lib.mkIf (cfg.type == "server") {
            "consul/${caKey}" = {
              sopsFile = cfg.serverSecretsFile;
            } // consulOpts;
          })
        ];

        templates."gossip.json" = {
          content = ''{ "encrypt": "${config.sops.placeholder."consul/gossip"}" }'';
        } // consulOpts;
      };
  };
}
