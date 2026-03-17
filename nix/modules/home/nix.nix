{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.terminal.programs.nix;
in
{
  options.terminal.programs.nix = {
    enable = lib.mkEnableOption "Enable nix related tools and settings.";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
      };
    };

    programs = {
      nix-index = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
