{
  lib,
  inputs,
  config,
  ...
}:
let
  cfg = config.terminal.programs.bat;
in
{
  options.terminal.programs.bat = {
    enable = lib.mkEnableOption "Enable bat.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      bat = {
        enable = true;

        config =
          let
            themeName = if config.os.theme.name == "kanagawa" then "kanagawa" else config.os.theme.fullName;
          in
          {
            theme = themeName;
          };

        themes = {
          kanagawa = {
            src = inputs.kanagawa-nvim;
            file = "extras/tmTheme/kanagawa.tmTheme";
          };
        };
      };
    };
  };
}
