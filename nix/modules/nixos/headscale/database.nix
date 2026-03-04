{ cfg, ... }:
{
  config,
  lib,
  flake,
  ...
}:
{
  config = lib.mkIf cfg.enable {
    containers = {
      headscale-db = flake.lib.mkContainer {
        inherit (cfg) hostAddress;
        localAddress = "10.0.0.2";
        ephemeral = false;

        bindMounts = {
          "/run/secrets" = {
            hostPath = "/run/secrets";
          };
        };

        config =
          { pkgs, ... }:
          {
            # Needed for sops-nix secret access.
            users.groups = {
              keys.members = [ "postgres" ];
            };

            systemd.services = {
              postgresql.postStart =
                let
                  passwordFile = config.sops.secrets."headscale/dbuser".path;
                in
                ''
                  $PSQL -tA <<'EOF'
                    DO $$
                    DECLARE password TEXT;
                    BEGIN
                      password := trim(both from replace(pg_read_file('${passwordFile}'), E'\n', '''));
                      EXECUTE format('ALTER ROLE headscale WITH PASSWORD '''%s''';', password);
                    END $$;
                  EOF
                '';
            };

            services = {
              postgresql = {
                enable = true;
                enableTCPIP = true;

                ensureUsers = [
                  {
                    name = "headscale";
                    ensureClauses.login = true;
                    ensureDBOwnership = true;
                  }
                ];

                ensureDatabases = [
                  "headscale"
                ];

                authentication = pkgs.lib.mkOverride 10 ''
                  #type database DBuser origin-address auth-method
                  local all            all           trust
                  host  headscale      headscale     10.0.0.0/24   md5
                '';
              };

              postgresqlBackup = {
                enable = true;
                databases = [
                  "headscale"
                ];
              };
            };

            networking.firewall.allowedTCPPorts = [ 5432 ];
          };
      };
    };
  };
}
