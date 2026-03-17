{
  lib,
  pkgs,
  config,
  inputs,
  flake,
  ...
}:
with lib;
let
  cfg = config.mailServer;
  domain = builtins.elemAt config.mailServer.domains 0;
in
{
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  options.mailServer = {
    enable = mkEnableOption "mailserver based on simple-nixos-mailserver.";

    domains = mkOption {
      type = types.listOf types.str;
      example = [ "example.com" ];
      default = [ ];
      description = "The domains that this mail server serves.";
    };

    subDomain = mkOption {
      type = types.str;
      default = "mail";
      defaultText = "mail";
      example = "subDomain = \"mail\"";
      description = "Sub domain of first item in ({option}`mailServer.domains`).";
    };

    secretsFile = mkOption {
      type = types.path;
      default = null;
      defaultText = "null";
      example = "./secrets.yaml";
      description = "Path to secrets.yaml for nix-sops.";
    };
  };

  config = mkIf cfg.enable rec {
    # TODO:
    # - Monitoring
    #   - [ ] Alert on backup failure
    # - Write logs to files?
    #   - Logrotate
    # - Fail2Ban
    # - endlessh

    mailserver = {
      inherit (cfg) enable domains;
      fqdn = "${cfg.subDomain}.${domain}";
      certificateScheme = "acme-nginx";

      loginAccounts = {
        "admin@${domain}" = {
          name = "admin";
          hashedPassword = "$2b$05$RrmkGl90Z3FRSv9LtUTE0./Z/hDTkWfRmeGtJ56mOOBm8Z3C8nIQG";
          aliases = [
            "postmaster@${domain}"
            "abuse@${domain}"
            "security@${domain}"
          ];
        };
        "olli@${domain}" = {
          hashedPassword = "$2b$05$HEsSsHI1nYd65q7EWOSxI.WBuu6DZW0HXfKQqNRrj.Pd3/lQE5SRq";
          name = "olli";
          aliases = [
            "hey@${domain}"
          ];
        };
      };

      mailboxes = {
        Drafts = {
          auto = "subscribe";
          specialUse = "Drafts";
        };
        Junk = {
          auto = "subscribe";
          specialUse = "Junk";
        };
        Sent = {
          auto = "subscribe";
          specialUse = "Sent";
        };
        Trash = {
          auto = "subscribe";
          specialUse = "Trash";
        };
      };
    };

    services =
      let
        mailAccounts = mailserver.loginAccounts;
        htpasswd = pkgs.writeText "radicale.users" (
          concatStrings (
            flip mapAttrsToList mailAccounts (mail: user: mail + ":" + user.hashedPassword + "\n")
          )
        );
      in
      rec {
        roundcube = {
          enable = true;
          hostName = "mail.${domain}";

          extraConfig = ''
            $config['smtp_host'] = "tls://${mailserver.fqdn}";
            $config['smtp_user'] = "%u";
            $config['smtp_pass'] = "%p";
            $config['username_domain'] = "%t";
          '';

          plugins = [
            "carddav"
            "contextmenu"
            "persistent_login"

            # FIXME: Below aren't working yet.
            "html5_notifier"
            "banner-ics"
            "gravatar"
            "tls_icon"
            "vacation"
            "roundcube_caldav"
            "automatic_addressbook"
            "dark_html"
            "attachment_preview"
          ];

          package = pkgs.roundcube.withPlugins (
            plugins:
            [
              plugins.contextmenu
              plugins.carddav
              plugins.persistent_login
            ]
            ++ roundcube.plugins
          );

          # FIXME: Is not working yet.
          dicts = with pkgs.aspellDicts; [
            en
            de
          ];
        };

        radicale = {
          enable = true;
          settings = {
            auth = {
              type = "htpasswd";
              htpasswd_filename = "${htpasswd}";
              htpasswd_encryption = "bcrypt";
            };
          };
        };

        nginx = {
          enable = true;
          virtualHosts = {
            "cal.${domain}" = {
              forceSSL = true;
              enableACME = true;
              locations."/" = {
                proxyPass = "http://localhost:5232/";
                extraConfig = ''
                  proxy_set_header  X-Script-Name /;
                  proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_pass_header Authorization;
                '';
              };
            };
          };
        };

        postgresqlBackup = {
          enable = true;
          databases = [
            "roundcube"
          ];
        };

        restic =
          let
            services = {
              mail = {
                paths = [ "/var/vmail" ];
              };
              dkim = {
                paths = [ "/var/dkim" ];
              };
              postgresql = {
                paths = [ "/var/backup/postgresql/roundcube*" ];
              };
              readicale = {
                paths = [ "/var/lib/radicale" ];
              };
            };
          in
          {
            backups = builtins.mapAttrs (name: settings: flake.lib.mkBackup name settings) services;
          };
      };

    security = {
      acme = {
        acceptTerms = true;
        defaults.email = "security@${domain}";
      };
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
