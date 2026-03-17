{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.graphical.programs.rofi;
in
{
  options.graphical.programs.rofi = {
    enable = mkEnableOption "Enable Rofi.";
  };

  config = mkIf cfg.enable {
    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-unwrapped;
        theme = ./gruvbox-material.rasi;

        extraConfig = {
          display-ssh = "";
          display-run = "";
          display-drun = "";
          display-window = "";
          display-combi = "";
          show-icons = true;
        };
      };
    };
  };
}
