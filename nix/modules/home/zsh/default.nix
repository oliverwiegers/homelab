{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.terminal.shell.zsh;
in
{
  options.terminal.shell.zsh = {
    enable = lib.mkEnableOption "Enable ZSH.";
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
        zsh-fzf-tab = {
          target = ".zsh/oh-my-zsh/custom/plugins/fzf-tab";
          source = inputs.zsh-fzf-tab;
        };

        zsh-syntax-highlighting = {
          target = ".zsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting";
          source = inputs.zsh-syntax-highlighting;
        };

        zsh-vi-mode = {
          target = ".zsh/oh-my-zsh/custom/plugins/zsh-vi-mode";
          source = inputs.zsh-vi-mode;
        };

        zsh-powerlevel10k = {
          target = ".zsh/oh-my-zsh/custom/themes/powerlevel10k";
          source = inputs.zsh-powerlevel10k;
        };

        ".p10k.zsh" = {
          target = ".p10k.zsh";
          source = ./p10k.zsh;
        };
      };
    };

    programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;

        # Keep "code" in zsh files to lint it.
        initContent = lib.strings.concatStrings [
          (builtins.readFile ./zsh_functions.zsh)
          (builtins.readFile ./zsh_settings.zsh)
          (if pkgs.stdenv.hostPlatform.isAarch64 then ''eval "$(/opt/homebrew/bin/brew shellenv)"'' else "")
        ];

        shellAliases = {
          ls = "exa --icons";
          l = "exa -lah --icons";
          ll = "exa -lh --icons";
          lt = "exa -T --icons";
          cat = "bat -pp";
          serv = "python3 -m http.server";
          wanip = "curl -s4 https://ip.syseleven.de";
          dev = "ls /dev/";
          weather = "curl -H \"Accept-Language: de\" wttr.in/Berlin";
          getcommittext = "curl -sL http://whatthecommit.com/index.txt";
          reload = ''rm -f ~/.zcompdump* && source $HOME/.zshrc && printf "Successfully reloaded zsh_config_files\n"'';
          conf = "dotedit";
          vtree = "tree -I .venv";
          vact = ". .venv/bin/activate";
          venv = "python3 -m virtualenv .venv";

          # git
          gct = "git fetch --all; git checkout --track";
          tmux = "tmux a || tmux";
        };

        oh-my-zsh = {
          enable = true;
          theme = "powerlevel10k/powerlevel10k";
          custom = "$HOME/.zsh/oh-my-zsh/custom/";

          plugins = [
            "copybuffer"
            "direnv"
            "docker"
            "fancy-ctrl-z"
            "fzf"
            "fzf-tab"
            "git"
            "golang"
            "jsontools"
            "pass"
            "rust"
            "sudo"
            "systemadmin"
            "taskwarrior"
            "zsh-syntax-highlighting"
            "zsh-vi-mode"
          ];
        };
      };
    };
  };
}
