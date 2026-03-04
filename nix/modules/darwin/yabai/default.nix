{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.wm.yabai;
in
{
  options.wm.yabai = {
    enable = mkEnableOption "Enable yabai WM.";
  };

  config = mkIf cfg.enable {
    services = {
      yabai = {
        enable = true;
        extraConfig = builtins.readFile ./yabairc;
        enableScriptingAddition = true;
        package = pkgs.yabai;
      };

      skhd = {
        enable = true;
        skhdConfig = builtins.readFile ./skhdrc;
      };
    };
  };
}
