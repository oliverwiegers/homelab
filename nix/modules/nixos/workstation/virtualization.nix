{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.workstation.virtualization;
in
{
  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = false;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };

      docker = {
        enable = true;
      };
    };
  };
}
