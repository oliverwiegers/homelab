{
  lib,
  config,
  ...
}:
let
  cfg = config.terminal.programs.fzf;
in
{
  options.terminal.programs.fzf = {
    enable = lib.mkEnableOption "Enable fzf.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
