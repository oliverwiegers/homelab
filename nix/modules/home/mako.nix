{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.graphical.services.mako;
in
{
  options.graphical.services.mako = {
    enable = mkEnableOption "Enable Mako.";
  };

  config = mkIf cfg.enable {
    services = {
      mako = {
        enable = true;
        settings = {
          borderSize = 1;
          borderRadius = 3;
          width = 400;
          height = 150;
          margin = "20,20,20";
          padding = "20,20,20";
          defaultTimeout = 30000;
          font = "SauceCodPro Nerd Font";
          format = ''<b>%s</b>\n\n%b'';
          backgroundColor = "${config.os.theme.colors.colors.primary.background}";
          textColor = "${config.os.theme.colors.colors.primary.foreground}";
          borderColor = "${config.os.theme.colors.colors.normal.black}";
          progressColor = "${config.os.theme.colors.colors.normal.green}";
        };
      };
    };
  };
}
