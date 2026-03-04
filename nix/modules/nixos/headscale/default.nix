{
  lib,
  config,
  ...
}:
let
  cfg = config.headscale;
in
{
  options.headscale = {
    enable = lib.mkEnableOption "Headscale server.";

    secretsFile = lib.mkOption {
      description = "Path to secrets.yaml for nix-sops containing headscale secrets.";
      type = lib.types.path;
      default = null;
      defaultText = "consul.secretsFile = null;";
      example = "consul.secretsFile = ./secrets/foo.yaml;";
    };

    hostAddress = lib.mkOption {
      description = "IP address of host. Needed for container network traffic.";
      type = lib.types.str;
      default = null;
    };

    domain = lib.mkOption {
      description = "Domain headscale service will run on.";
      type = lib.types.str;
      default = null;
    };

    internalDomain = lib.mkOption {
      description = "Internal domain of tailnet.";
      type = lib.types.str;
      default = null;
    };
  };

  imports = [
    (import ./service.nix { inherit cfg; })
    (import ./database.nix { inherit cfg; })
  ];

  config = lib.mkIf cfg.enable {
    # security.acme.certs."vpn.${cfg.domain}" = { };
    # systemd.services."container@headscale".wants = [ "acme-vpn.${cfg.domain}.service" ];
  };
}
