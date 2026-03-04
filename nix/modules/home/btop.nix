{
  lib,
  config,
  ...
}:
let
  cfg = config.terminal.programs.btop;
in
{
  options.terminal.programs.btop = {
    enable = lib.mkEnableOption "Enable btop.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      btop = {
        enable = true;
        settings = {
          color_theme = "TTY";
        };
      };
    };
  };
}
