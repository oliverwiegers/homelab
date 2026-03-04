{
  lib,
  config,
  ...
}:
let
  cfg = config.terminal.programs.git;
in
{
  options.terminal.programs.git = {
    enable = lib.mkEnableOption "Enable git.";
    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;

        settings = {
          commit = {
            gpgsign = true;
          };
          init = {
            defaultBranch = "main";
          };
          "protocol \"http\"" = {
            allow = "never";
          };
          "protocol \"git\"" = {
            allow = "never";
          };
          difftool = {
            trustExitCode = true;
            prompt = false;
          };
        } // cfg.extraConfig;
      };

      difftastic = {
        enable = true;
        git.enable = true;
      };

      zsh = lib.mkIf config.terminal.shell.zsh.enable {
        # Use difftastic for log and show as well'''.
        shellAliases = {
          glgp = "git log --patch --ext-diff";
          gsh = "git show --ext-diff";
          gsps = "git show --pretty=short --show-signature --ext-diff";
        };
      };
    };
  };
}
