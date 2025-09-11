{config, lib, ...}:
let
  cfg = config.services.networking.syncthing;
in {
  options.services.networking.syncthing = {
    enable = lib.mkEnableOption "Syncthing.";

  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      settings = {
        gui = {
          user = "oliverwiegers";
          # password = builtins.readFile "${config.sops.secrets.syncthing.path}";
        };
      };
    };
  };
}
