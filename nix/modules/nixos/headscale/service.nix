{ cfg, ... }:
{ config, lib, ... }:
{
  config = lib.mkIf cfg.enable {
    containers = {
      headscale = {
        inherit (cfg) hostAddress;
        localAddress = "10.0.0.1";

        bindMounts = {
          "/run/secrets" = {
            hostPath = "/run/secrets";
          };
        };

        config = _: {
          # Needed for sops-nix secret access.
          users.groups = {
            keys.members = [ "headscale" ];
            acme.members = [ "headscale" ];
          };

          # services = {
          #   headscale = let
          #     certDir = config.security.acme.certs.${FQDN}.directory;
          #   in {
          #     enable = true;

          #     settings = {
          #       tls_key_path = certDir + "/key.pem";
          #       tls_chain_path = certDir + "/fullchain.pem";
          #       server_url = "https://${FQDN}";

          #       dns = {
          #         search_domains = [cfg.internalDomain];
          #         base_domain = cfg.internalDomain;
          #       };

          #       database = {
          #         type = "postgres";

          #         postgres = {
          #           user = "headscale";
          #           name = "headscale";
          #           host = "10.0.0.2";
          #           port = 5432;
          #           password_file = config.sops.secrets."headscale/dbuser".path;
          #         };
          #       };
          #     };

          #     # extraSettings = {
          #     #   dns.extra_records = [
          #     #     {
          #     #       name = "consul.${cfg.internalDomain}";
          #     #       type = "A";
          #     #       value = "100.64.0.3";
          #     #     }
          #     #   ];
          #     # };
          #   };
          # };
        };
      };
    };
  };
}
