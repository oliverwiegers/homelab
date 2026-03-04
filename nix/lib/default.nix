{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
in {
  #     ______                 __  _
  #    / ____/_  ______  _____/ /_(_)___  ____  _____
  #   / /_  / / / / __ \/ ___/ __/ / __ \/ __ \/ ___/
  #  / __/ / /_/ / / / / /__/ /_/ / /_/ / / / (__  )
  # /_/    \__,_/_/ /_/\___/\__/_/\____/_/ /_/____/

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
