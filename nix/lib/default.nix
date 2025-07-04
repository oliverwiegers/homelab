{ lib, ... }:
rec {
  #     ______                 __  _
  #    / ____/_  ______  _____/ /_(_)___  ____  _____
  #   / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
  #  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
  # /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

  patchesPresent =
    if
      lib.filesystem.pathIsDirectory ../patches
      && builtins.length (lib.filesystem.listFilesRecursive ../patches) > 0
    then
      true
    else
      false;

  getFilesBySuffix =
    dir: suffix:
    map (path: dir + "/${path}") (
      builtins.filter (file: lib.hasSuffix suffix file) (
        builtins.attrNames (builtins.readDir (builtins.toString dir))
      )
    );

  getConfigFilePaths =
    dir:
    map (path: dir + "/${path}") (
      builtins.filter (file: lib.hasSuffix ".nix" file && file != "default.nix") (
        builtins.attrNames (builtins.readDir (builtins.toString dir))
      )
    );

  getDirectoryPaths =
    dir:
    map (path: dir + "/${path}") (
      builtins.attrNames (
        lib.attrsets.filterAttrs (_: type: type == "directory") (builtins.readDir (builtins.toString dir))
      )
    );

  # Override function nixosSystem to be able to apply patches to nixOS modules.
  # See here: https://github.com/NixOS/nixpkgs/pull/142273#issuecomment-948225922
  # Native support is planned here: https://github.com/NixOS/nix/issues/3920
  mkHost =
    {
      inputs,
      outputs,
      helpers,
      self,
      nixosSystem,
      hostname,
      os,
    }:
    (if os == "nixos" then nixosSystem else lib.darwinSystem) {
      specialArgs = {
        inherit
          helpers
          inputs
          outputs
          self
          ;
      };

      system = if os == "nixos" then null else "aarch64-darwin";

      modules =
        let
          moduleList = ../modules/${os}/module-list.nix;
        in
        [
          (../hosts + "/${os}" + "/${hostname}")
          { networking.hostName = lib.mkDefault "${hostname}"; }
        ]
        ++ lib.lists.optionals (builtins.pathExists moduleList) (import moduleList);
    };

  mkHostConfigs =
    {
      inputs,
      outputs,
      helpers,
      self,
      nixosSystem ? lib.nixosSystem,
      os ? "nixos",
    }:
    builtins.mapAttrs
      (
        host: _:
        mkHost {
          inherit
            os
            self
            nixosSystem
            helpers
            inputs
            outputs
            ;
          hostname = "${host}";
        }
      )
      (
        lib.attrsets.filterAttrs (_: type: type == "directory") (
          builtins.readDir (builtins.toString (../hosts + "/${os}"))
        )
      );

  mkBackup =
    name: settings:
    {
      initialize = true;
      runCheck = true;
      repository = "/var/backups/restic/${name}";
      passwordFile = "/run/secrets/restic/${name}";

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 3"
      ];

      extraBackupArgs = [
        "--tag daily"
      ];
    }
    // settings;

  mkContainer =
    settings:
    {
      autoStart = true;
      privateNetwork = true;
      ephemeral = true;

      config = {
        containerConfigDefaults = {
          services.resolved.enable = true;

          networking = {
            firewall.enable = true;
            # Use systemd-resolved inside the container
            # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
            useHostResolvConf = lib.mkForce false;
          };
        };
      };
    }
    // settings;

  #    _____       _                  __
  #   / ___/____  (_)___  ____  ___  / /______
  #   \__ \/ __ \/ / __ \/ __ \/ _ \/ __/ ___/
  #  ___/ / / / / / /_/ / /_/ /  __/ /_(__  )
  # /____/_/ /_/_/ .___/ .___/\___/\__/____/
  #             /_/   /_/

  ## Quickly enable an option.
  ##
  ## ```nix
  ##   services.openssh = enabled;
  ## ```
  ##
  enabled = {
    enable = true;
  };

  ## Quickly disable an option.
  ##
  ## ```nix
  ##   services.openssh = disabled;
  ## ```
  ##
  disabled = {
    enable = false;
  };

  #     __  ___     __            __      __
  #    /  |/  /__  / /_____ _____/ /___ _/ /_____ _
  #   / /|_/ / _ \/ __/ __ `/ __  / __ `/ __/ __ `/
  #  / /  / /  __/ /_/ /_/ / /_/ / /_/ / /_/ /_/ /
  # /_/  /_/\___/\__/\__,_/\__,_/\__,_/\__/\__,_/

  _metadata = builtins.fromJSON (builtins.readFile ../.homelab.json);
}
