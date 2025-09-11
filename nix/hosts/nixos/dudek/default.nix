{
  # pkgs,
  # config,
  helpers,
  inputs,
  self,
  ...
}:
let
  host = baseNameOf ./.;
  hostAddress = helpers._metadata.hosts.${host}.primaryIPv4;
  inherit (helpers._metadata.hosts.${host}) hostId;
in
{
  imports = [
    "${self}/nix/modules/nixos/profiles/nix-settings.nix"
    "${self}/nix/modules/nixos/profiles/acme-defaults.nix"
    "${self}/nix/modules/nixos/profiles/sops-defaults.nix"

    inputs.sops-nix.nixosModules.sops
  ];

  #    ______           __                     __  ___          __      __
  #   / ____/_  _______/ /_____  ____ ___     /  |/  /___  ____/ /_  __/ /__  _____
  #  / /   / / / / ___/ __/ __ \/ __ `__ \   / /|_/ / __ \/ __  / / / / / _ \/ ___/
  # / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /  / / /_/ / /_/ / /_/ / /  __(__  )
  # \____/\__,_/____/\__/\____/_/ /_/ /_/  /_/  /_/\____/\__,_/\__,_/_/\___/____/

  # tailscale = {
  #   enable = true;
  #   authKeyFile = config.sops.secrets."headscale/preauthkey".path;
  # };

  base.stateVersion = "25.11";

  zfsRoot = {
    enable = true;
    inherit hostId;
  };

  headscale = {
    enable = false;
    secretsFile = ./secrets.yaml;
    inherit (helpers._metadata) domain internalDomain;
    inherit hostAddress;
  };

  serverBase = {
    enable = true;

    #  fancyMotd.extraServices = ''
    #    services["nginx"]="Nginx"
    #    services["dovecot2"]="Dovecot"
    #    services["postfix"]="Postfix"
    #    services["opendkim"]="DKIM"
    #    services["redis-server"]="Redis"
    #    services["phpfpm-roundcube"]="Roundcube"
    #    services["radicale"]="Radicale"
    #    services["postgresql"]="PostgreSQL"
    #    services["headscale"]="Headscale"
    #  '';
  };

  # mailServer = {
  #   enable = false;
  #   domains = [domain];
  #   subDomain = "mail";
  #   secretsFile = ./secrets.yaml;
  # };

  # consul = {
  #   enable = false;
  #   type = "server";
  #   #bindAddr = "100.64.0.3";
  #   #uiBindAddr = "100.64.0.3";
  #   clientSecretsFile = "${self}/secrets.yaml";
  #   serverSecretsFile = ./secrets.yaml;
  # };

  #     _   ___      ____  _____
  #    / | / (_)  __/ __ \/ ___/
  #   /  |/ / / |/_/ / / /\__ \
  #  / /|  / />  </ /_/ /___/ /
  # /_/ |_/_/_/|_|\____//____/

  #services = {
  #  nginx = {
  #    enable = false;

  #    upstreams = {
  #      headscale.servers = {
  #        "${localHeadscaleURI}" = {};
  #      };

  #      consul.servers = {
  #        "100.64.0.1:8500" = {};
  #        "100.64.0.3:8500" = {};
  #        "100.64.0.4:8500" = {};
  #      };
  #    };

  #    virtualHosts = {
  #      "${headscaleFQDN}" = {
  #        forceSSL = true;
  #        enableACME = true;
  #        acmeRoot = null; # Needed for DNS challenge to work.
  #        locations."/" = {
  #          proxyPass = "http://headscale";
  #          proxyWebsockets = true;
  #        };
  #      };

  #      "consul.${domainInternal}" = {
  #        forceSSL = true;
  #        enableACME = true;
  #        acmeRoot = null; # Needed for DNS challenge to work.
  #        locations."/" = {
  #          proxyPass = "http://consul";
  #          proxyWebsockets = true;
  #        };
  #      };
  #    };
  #  };

  #  restic = let
  #    services = {
  #      postgresql = {
  #        paths = ["/var/backup/postgresql"];
  #      };
  #    };
  #  in {
  #    backups = builtins.mapAttrs (name: settings: helpers.mkBackup name settings) services;
  #  };
  #};

  #  tailscaled-autoconnect = {
  #    after = ["headscale.service"];
  #    wants = ["headscale.service"];
  #  };

  #   ________    _          __   ____             __
  #  /_  __/ /_  (_)________/ /  / __ \____ ______/ /___  __
  #   / / / __ \/ / ___/ __  /  / /_/ / __ `/ ___/ __/ / / /
  #  / / / / / / / /  / /_/ /  / ____/ /_/ / /  / /_/ /_/ /
  # /_/ /_/ /_/_/_/   \__,_/  /_/    \__,_/_/   \__/\__, /
  #                                                /____/

  sops = {
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      desec = {
        sopsFile = "${self}/nix/secrets.yaml";
        group = "keys";
        mode = "0440";
      };

      "headscale/dbuser" = {
        group = "keys";
        mode = "0440";
      };

      "headscale/preauthkey" = { };
      "restic/mail" = { };
      "restic/dkim" = { };
      "restic/radicale" = { };
      "restic/postgresql" = { };
    };
  };
}
