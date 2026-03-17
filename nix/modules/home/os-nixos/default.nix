{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.os.nixos;
in
{
  options.os.nixos = {
    enable = mkEnableOption "Enable nixos default settings for home-manager user.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qt5.qtwayland
      qt6.qtwayland
      libnotify
      wl-clipboard
      pavucontrol
      imv
      signal-desktop
      brightnessctl
      android-tools
    ];
  };
}
