{
  lib,
  config,
  ...
}:
let
  cfg = config.monitoring;
in
{
  options.monitoring = {
    enable = lib.mkEnableOption "Prometheus server.";
  };

  config = lib.mkIf cfg.enable {
    services = { };
  };
}
