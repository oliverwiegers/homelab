{ cfg, rootSnapshot, ... }:
{ lib, ... }:
{
  config = lib.mkIf cfg.enable {
    fileSystems."/nix".neededForBoot = true;
    fileSystems."/etc/ssh".neededForBoot = true;

    disko.devices = {
      disk = {
        main = {
          type = "disk";
          inherit (cfg) device;

          content = {
            type = "gpt";
            partitions = {
              # Hetzner Cloud VMs don't support UEFI so we need to user BIOS boot.
              boot = {
                size = "1M";
                type = "EF02";
                priority = 1;
              };
              ESP = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                    "umask=0077"
                  ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = cfg.zpool;
                };
              };
            };
          };
        };
      };

      zpool = {
        ${cfg.zpool} = {
          type = "zpool";
          rootFsOptions = {
            canmount = "off";
            compression = "on";
            acltype = "posixacl"; # Needed for users to be able to read their own journal.
            xattr = "sa";
          };

          datasets = lib.mkMerge [
            {
              # Root filesystem.
              ${cfg.systemDataset} = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };
              "${cfg.systemDataset}/root" = {
                type = "zfs_fs";
                mountpoint = "/";
                postCreateHook = lib.mkIf cfg.impermanence "zfs snapshot ${rootSnapshot}";
                options = {
                  mountpoint = "legacy";
                  refquota = "1G";
                };
              };
            }

            (lib.mkIf cfg.impermanence {
              # Files that can be recreated from config but we would like to keep anyway between boots
              # because recreation would be time consuming or otherwise unpractical.
              "local" = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };
              "local/nix" = {
                type = "zfs_fs";
                mountpoint = "/nix";
                options = {
                  mountpoint = "legacy";
                  refquota = "5G";
                };
              };
              "local/etc/ssh" = {
                type = "zfs_fs";
                mountpoint = "/etc/ssh";
                options = {
                  mountpoint = "legacy";
                  refquota = "1M";
                };
              };

              # Files that need to be backed up.
              "safe" = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };
              "safe/home" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/home";
              };
            })
          ];
        };
      };
    };
  };
}
