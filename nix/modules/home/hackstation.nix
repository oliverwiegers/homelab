{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.hackstation;
in
{
  options = {
    hackstation = {
      enable = mkEnableOption "Install pentest tools.";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      burpsuite
      dnsutils
      amass
      nmap
      python3Packages.shodan
    ];
  };
}
