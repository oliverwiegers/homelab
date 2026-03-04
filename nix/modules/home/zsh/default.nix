{
  lib,
  pkgs,
  config,
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
        # TODO: Yeah software to never update again.
        # This is ugly as hell. Need to fix this.
        "fzf-tab" = {
          target = ".zsh/oh-my-zsh/custom/plugins/fzf-tab";
          source = pkgs.fetchFromGitHub {
            leaveDotGit = true;
            deepClone = true;
            fetchSubmodules = true;
            owner = "Aloxaf";
            repo = "fzf-tab";
            rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
            sha256 = "gvZp8P3quOtcy1Xtt1LAW1cfZ/zCtnAmnWqcwrKel6w=";
          };
        };

        "zsh-syntax-highlighting" = {
          target = ".zsh/oh-my-zsh/custom/plugins/zsh-syntax-highlighting";
          source = pkgs.fetchFromGitHub {
            leaveDotGit = true;
            deepClone = true;
            fetchSubmodules = true;
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "143b25eb98aa3227af63bd7f04413e1b3e7888ec";
            sha256 = "QuzjU9yuGEcPPRX2H3eatxP77cqPdD3GTNcp4TPfdJ8=";
          };
        };

        "powerlevel10k" = {
          target = ".zsh/oh-my-zsh/custom/themes/powerlevel10k";
          source = pkgs.fetchFromGitHub {
            leaveDotGit = true;
            fetchSubmodules = true;
            owner = "romkatv";
            repo = "powerlevel10k";
            rev = "174ce9bf0166c657404a21f4dc9608da935f7325";
            sha256 = "AAKcgVcxTbx2YbJ8xgjT7532BLU2NRFIIsOd779OIGI=";
          };
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
          ];
        };
      };
    };
  };
}
