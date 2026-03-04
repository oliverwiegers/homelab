{
  lib,
  pkgs,
  config,
  flake,
  inputs,
  modulesPath,
  ...
}:
let
  cfg = config.serverBase;
in
{
  imports = [
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    "${flake}/nix/profiles/acme-defaults.nix"
    "${flake}/nix/profiles/sops-defaults.nix"

    inputs.sops-nix.nixosModules.sops
  ];

  options.serverBase = {
    enable = lib.mkEnableOption "base server configuration.";

    fancyMotd.extraServices = lib.mkOption {
      type = lib.types.str;
      default = "";
      defaultText = "";
      example = ''
        services["nginx"]="Nginx"
      '';
      description = "Additional services to show in motd.";
    };

    containers.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "settings needed for nixos-containers (systemd-nspawn).";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "xhci_pci"
          "virtio_pci"
          "virtio_scsi"
          "sd_mod"
          "sr_mod"
        ];
      };
    };

    sops = {
      secrets = {
        initialRootPassword = {
          sopsFile = "${flake}/nix/secrets.yaml";
          neededForUsers = true;
        };
      };
    };

    users = {
      mutableUsers = true;

      users = {
        root = {
          hashedPasswordFile = config.sops.secrets.initialRootPassword.path;

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKvcXlse6olKBEiRpfPclT4Pn31lpQ4fbZHNv5MBXat"
          ];
        };
      };
    };

    environment = {
      systemPackages = with pkgs; [
        vim-full
        dhcpcd
        nettools
        inetutils
        wget
        htop
        jq
        goaccess
        tmux
        restic
        dig
        lazyjournal

        # fancy-motd
        fancy-motd
        figlet
        bc
        curl
        fortune
        lm_sensors
      ];

      variables = {
        EDITOR = "vim";
      };

      etc = {
        fancy-motd =
          let
            defaultConfig = ''
              # Colors
              CA="\e[34m"  # Accent
              CO="\e[32m"  # Ok
              CW="\e[33m"  # Warning
              CE="\e[31m"  # Error
              CN="\e[0m"   # None

              # Max width used for components in second column
              WIDTH=50

              # Services to show
              declare -A services
              services["sshd"]="SSH"
              services["tailscaled"]="Tailscale"
            '';
          in
          {
            text = lib.concatStrings [
              defaultConfig
              cfg.fancyMotd.extraServices
            ];
          };
      };
    };

    networking = {
      useDHCP = lib.mkDefault true;

      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
        "8.8.8.8"
        "2606:4700:4700::1111"
        "2606:4700:4700::1001"
      ];

      nat = lib.mkIf cfg.containers.enable {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "enp1s0";
      };
    };

    services = {
      openssh = {
        enable = true;
        allowSFTP = false;

        settings = {
          PasswordAuthentication = false;
          LogLevel = "VERBOSE";
        };

        hostKeys = [
          {
            path = "/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };

      resolved = {
        enable = true;
      };

      qemuGuest = {
        enable = true;
      };

      prometheus.exporters = {
        node = {
          enable = true;
          enabledCollectors = [
            "logind"
            "systemd"
            "mountstats"
          ];
        };
      };

      fail2ban.enable = true;
    };

    documentation = {
      enable = true;
      nixos.options.warningsAreErrors = false;
      info.enable = false;
    };

    system.activationScripts.root_profile = ''
      printf '%s\n' 'motd /etc/fancy-motd' > /root/.profile
    '';
  };
}
