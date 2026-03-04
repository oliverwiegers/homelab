{
  lib,
  perSystem,
  config,
  ...
}:
let
  cfg = config.terminal.programs.tmux;
in
{
  options.terminal.programs.tmux = {
    enable = lib.mkEnableOption "Enable tmux.";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      tmux = {
        enable = true;
        package = perSystem.tmuxist.tmux;
      };
    };

    home = {
      file = {
        ".tmux.conf.local" = {
          target = ".tmux.conf.local";
          text = ''
            # : <<EOF
            unbind-key C-b
            set -g prefix C-k
            bind-key C-k send-prefix
            # EOF
          '';
        };
      };
    };
  };
}
