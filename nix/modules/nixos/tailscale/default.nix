{
  lib,
  config,
  ...
}:
let
  cfg = config.tailscale;
in
{
  imports = [
    ./monitoring.nix
  ];

  options.tailscale = {
    enable = lib.mkEnableOption "Tailscale client.";

    authKeyFile = lib.mkOption {
      description = "File that contains preauthkey.";
      type = lib.types.path;
      default = null;
      defaultText = "";
      example = "";
    };

    isExitNode = lib.mkOption {
      description = "Set this node as a exit node.";
      type = lib.types.bool;
      default = false;
      defaultText = "false";
      example = "true";
    };

    serverURL = lib.mkOption {
      description = "";
      type = lib.types.str;
      default = null;
      defaultText = "";
      example = "";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.authKeyFile != null;
        message = "authKeyFile must be set";
      }
    ];

    services.tailscale = {
      enable = true;

      inherit (cfg) authKeyFile;

      extraUpFlags = [
        "--login-server"
        cfg.serverURL
      ];
    };

    networking.firewall = {
      enable = true;
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
