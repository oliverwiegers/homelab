{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.prometheus.exporters.consul;
  inherit (lib) mkOption types concatStringsSep;
in
{
  port = 9119;
  extraOpts = {
    consulServer = mkOption {
      type = types.str;
      default = "http://localhost:8500/";
      description = ''
        Consul agent address.
      '';
    };
    consulTimeout = mkOption {
      type = types.str;
      default = "500ms";
      description = ''
        Timeout for trying to get stats from Consul.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-consul-exporter}/bin/consul_exporter \
          --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
          --consul.server ${cfg.consulServer} \
          --consul.timeout ${toString cfg.consulTimeout} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
