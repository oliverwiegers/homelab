{
  lib,
  config,
  ...
}:
let
  cfg = config.tailscale;
  promDir = "/var/lib/prometheus/node-exporter";
in
{
  config = lib.mkIf cfg.enable {
    systemd.timers."tailscale-metrics" = {
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "tailscale-metrics.service";
      };
    };

    systemd.services."tailscale-metrics" = {
      after = [ "prometheus-node-exporter.service" ];
      wants = [ "prometheus-node-exporter.service" ];
      script = ''
        set -eu

        if ! [ -d "${promDir}" ]; then
          mkdir -p "${promDir}"
        fi

        ${config.services.tailscale.package}/bin/tailscale metrics write ${promDir}/tailscaled.prom
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    services.prometheus.exporters.node.extraFlags = [
      "--collector.textfile.directory ${promDir}"
    ];
  };
}
