{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.graphical.programs.gtk;
in
{
  options.graphical.programs.gtk = {
    enable = lib.mkEnableOption "Enable GTK.";
  };

  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = "gruvbox-dark";
        package = pkgs.gruvbox-dark-gtk;
      };

      iconTheme = {
        name = "gruvbox-dark";
        package = pkgs.gruvbox-dark-icons-gtk;
      };
    };
  };
}
