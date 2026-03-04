{
  pkgs,
  config,
  lib,
  flake,
  ...
}:
with lib;
let
  cfg = config.workstation;
  inherit (flake.lib) _metadata;
in
{
  imports = [
    ./wm.nix
    ./wifi.nix
    ./audio.nix
    ./laptop.nix
    ./virtualization.nix
  ];

  options = {
    workstation = {
      enable = mkEnableOption "Enable settings for use as workstation.";

      audio = {
        enable = mkEnableOption "Enable audio using PipeWire.";
      };

      bluetooth = {
        enable = mkEnableOption "Enable bluetooth.";
      };

      laptop = {
        enable = mkEnableOption "Enable laptop settings like power management.";
      };

      virtualization = {
        enable = mkEnableOption "Enable virtualization using Podman.";
      };

      wifi = {
        enable = mkEnableOption "Enable wireless networking.";
      };

      wm = {
        enable = mkEnableOption "Enable window manager settings using Hyprland.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Boot settings.
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };

      kernel = {
        sysctl = {
          "net.ipv4.ip_forward" = true;
        };
      };
    };

    users.users = {
      oliverwiegers = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
        ];
        description = "Oliver Wiegers";
        shell = pkgs.zsh;
      };
    };

    environment = {
      systemPackages = with pkgs; [
        vim-full
        dhcpcd
        wpa_supplicant
        nettools
        inetutils
        wget
        git
      ];
    };

    programs = {
      gnupg = {
        agent = {
          enable = true;
        };
      };

      zsh = {
        enable = true;
      };
    };

    fileSystems = {
      "/media/nas" = {
        device = "daedalus.${_metadata.homeDomain}:/mnt/carter/olli";
        fsType = "nfs";
        options = [ "nofail" ];
      };
      "/media/nas_vanessa" = {
        device = "daedalus.${_metadata.homeDomain}:/mnt/carter/vanessa";
        fsType = "nfs";
        options = [ "nofail" ];
      };
    };

    security = {
      sudo = {
        enable = true;
        extraRules = [
          {
            users = [ "oliverwiegers" ];
            commands = [
              {
                command = "ALL";
                options = [
                  "NOPASSWD"
                  "SETENV"
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
