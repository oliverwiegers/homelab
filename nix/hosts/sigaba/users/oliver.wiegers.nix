{
  lib,
  config,
  pkgs,
  inputs,
  flake,
  ...
}:
let
  username = "oliver.wiegers";
in {
  imports = builtins.concatLists [
    (builtins.attrValues flake.modules.home)

    [
      inputs.sops-nix.homeManagerModules.sops
    ]
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/oliver.wiegers";
    stateVersion = "23.05";

    activation.makeTrampolineApps = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      builtins.readFile ./make-app-trampolines.sh
    );
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  services.networking.syncthing.enable = true;
  sops = {
    gnupg.home = "/Users/${username}/.gnupg";
    secrets.syncthing.sopsFile = "${flake}/nix/secrets.yaml";
  };

  os = {
    darwin = flake.lib.enabled;

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
    shell.zsh = flake.lib.enabled;

    emulator = {
      alacritty = {
        enable = true;
        font.size = 16;
      };
    };

    programs = {
      bat = flake.lib.enabled;
      btop = flake.lib.enabled;
      direnv = flake.lib.enabled;
      fzf = flake.lib.enabled;
      home-manager = flake.lib.enabled;
      nix = flake.lib.enabled;
      terraform = flake.lib.enabled;
      tmux = flake.lib.enabled;
      github = flake.lib.enabled;
      # rust = enabled;
      k8s-cli = flake.lib.enabled;


      ssh = {
        enable = true;

        extraMatchBlocks = {
          jumphost = {
            user = "wiegers";
            hostname = "aptdater03.infra.netlogix-ws.cust.nlxnet.de";
            extraOptions = {
              RequestTTY = "yes";
              RemoteCommand = "tmux -L tmux new-session -As hacktheplanet";
            };
          };
        };
      };

      git = {
        enable = true;
        extraConfig = {
          user = {
            email = "oliver.wiegers@netlogix.de";
            name = "oliverwiegers";
            signingkey = "7DE42A84CF1FCCEC4EB9CAE8AFF11CB49BACA5D6";
          };

          gpg = {
            program = "gpg2";
          };
        };
      };
    };
  };

  graphical = {
    browser = {
      firefox = {
        enable = true;
        # package = pkgs.firefox-bin;
        # Workaround. See here: https://github.com/nix-community/home-manager/issues/6955#issuecomment-2878146879
        package = lib.makeOverridable ({...}: pkgs.firefox-bin) {};
      };
    };
  };
}
