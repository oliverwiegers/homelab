{
  lib,
  config,
  ...
}:
let
  cfg = config.terminal.programs.home-manager;
in
{
  options.terminal.programs.home-manager = {
    enable = lib.mkEnableOption "Enable home-manager.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      home-manager = {
        enable = true;
      };
    };
  };
}
