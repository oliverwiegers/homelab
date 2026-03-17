{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.zfsRoot;
  rootSnapshot = "${cfg.zpool}/${cfg.systemDataset}/root@start";
in
{
  options.zfsRoot = {
    enable = lib.mkEnableOption "zfs root file system.";

    impermanence = lib.mkOption {
      description = "Whether to erase root pationtion on boot.";
      type = lib.types.bool;
      default = true;
    };

    hostId = lib.mkOption {
      description = "Value for networking.hostId.";
      type = lib.types.str;
      default = null;
    };

    device = lib.mkOption {
      description = "Block device to install OS on.";
      type = lib.types.str;
      default = "/dev/sda";
    };

    zpool = lib.mkOption {
      description = "Name of zpool for data.";
      type = lib.types.str;
      default = "nixos";
    };

    systemDataset = lib.mkOption {
      description = "Name of dataset for root partition.";
      type = lib.types.str;
      default = "system";
    };
  };

  imports = [
    (import ./disk-config.nix { inherit cfg rootSnapshot; })

    inputs.disko.nixosModules.disko
  ];

  config = lib.mkIf cfg.enable {
    networking = {
      inherit (cfg) hostId;
    };
    services.zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    boot = {
      kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;
      supportedFilesystems = [ "zfs" ];

      zfs = {
        forceImportRoot = false;
        # See: https://discourse.nixos.org/t/zfs-with-disko-faluire-to-import-zfs-pool/61988/4
        devNodes = "/dev/disk/by-uuid";
      };

      # Hetzner Cloud VMs don't support UEFI boot.
      loader = {
        grub = {
          enable = true;
          zfsSupport = true;
        };
      };

      initrd = {
        systemd = {
          enable = true;
          services.initrd-rollback-root = {
            after = [ "zfs-import-${cfg.zpool}.service" ];
            wantedBy = [ "initrd.target" ];
            before = [ "sysroot.mount" ];
            path = [ pkgs.zfs ];
            description = "Rollback root fs";
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = "zfs rollback -r ${rootSnapshot}";
          };
        };
      };
    };
  };
}
