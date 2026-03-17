{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.terminal.programs.github;
in
{
  options.terminal.programs.github = {
    enable = lib.mkEnableOption "Enable GitHub CLI.";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-actions-cache
          gh-eco
          gh-markdown-preview
          gh-dash
        ];

        settings = {
          git_protocol = "ssh";
        };
      };
    };
  };
}
