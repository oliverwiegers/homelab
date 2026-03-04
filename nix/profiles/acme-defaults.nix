{
  config,
  flake,
  ...
}:
let
  inherit (flake.lib) _metadata;
in
{
  config = {
    security = {
      acme = {
        acceptTerms = true;

        defaults = {
          inherit (_metadata.acme) dnsProvider dnsResolver;
          email = "security@${_metadata.domain}";
          group = "acme";
          credentialFiles = {
            DESEC_TOKEN_FILE = config.sops.secrets.desec.path;
          };
          extraLegoFlags = [
            "--dns.propagation-wait"
            "300s"
          ];
        };
      };
    };
  };
}
