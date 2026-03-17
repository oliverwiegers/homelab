{
  inputs,
  flake,
  config,
  ...
}:
let
  inherit (flake.lib) _metadata;
in
{
  imports = builtins.attrValues flake.modules.home;

  home = {
    username = "oliverwiegers";
    homeDirectory = "/home/oliverwiegers";
    stateVersion = "23.05";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  fonts.fontconfig.enable = true;

  os = {
    nixos.enable = true;

    theme = rec {
      fullName =
        if config.os.theme.variant != null then
          "${config.os.theme.name}_${config.os.theme.variant}"
        else
          "${config.os.theme.name}";

      colors = builtins.fromTOML (builtins.readFile "${inputs.alacritty-theme}/themes/${fullName}.toml");
    };
  };

  terminal = {
    shell = {
      zsh.enable = true;
    };

    emulator = {
      alacritty = {
        enable = true;
        font.size = 11;
      };
    };

    programs = {
      bat.enable = true;
      btop.enable = true;
      direnv.enable = true;
      fzf.enable = true;
      home-manager.enable = true;
      newsboat.enable = true;
      nix.enable = true;
      tmux.enable = true;
      # terraform.enable = true;

      ssh = {
        enable = true;
        extraMatchBlocks = {
          kali = {
            user = "root";
            hostname = "10.5.0.5";
            extraOptions = {
              StrictHostKeyChecking = "no";
              RequestTTY = "yes";
              RemoteCommand = "tmux -L tmux new-session -As hacktheplanet";
              UserKnownHostsFile = "/dev/null";
            };
          };

          hackthebox = {
            user = "root";
            hostname = "10.10.0.10";
            extraOptions = {
              StrictHostKeyChecking = "no";
              RequestTTY = "yes";
              RemoteCommand = "tmux -L tmux new-session -As hacktheplanet";
              UserKnownHostsFile = "/dev/null";
            };
          };

          router = {
            user = "root";
            hostname = "router.${_metadata.homeDomain}";
            identityFile = "~/.ssh/id_rsa";
            extraOptions = {
              requestTTY = "yes";
              HostKeyAlgorithms = "+ssh-rsa";
            };
          };
        };
      };

      git = {
        enable = true;
        extraConfig = {
          user = {
            email = "oliver.wiegers@gmail.com";
            name = "oliverwiegers";
            signingkey = "244D3FF3276A942F8666536FDE9FDB17F778EFDA";
          };
          commit = {
            gpgsign = true;
          };
          gpg = {
            program = "gpg2";
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
        };
      };
    };
  };

  graphical = {
    browser = {
      firefox.enable = true;
    };

    programs = {
      gtk.enable = true;
      rofi.enable = true;
      zathura.enable = true;
    };

    services = {
      mako.enable = true;
    };
  };

  wm = {
    hyprland.enable = true;
  };

  # hackstation.enable = true;
}
