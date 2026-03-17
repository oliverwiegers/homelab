{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.os.darwin;
in
{
  options.os.darwin = {
    enable = mkEnableOption "Enable darwin default settings for home-manager user.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      gnupg
      ruby
      sshuttle
      gnutar
      wget
      ipcalc
    ];
  };
}
