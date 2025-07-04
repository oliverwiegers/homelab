{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.workstation.audio;
in
{
  config = mkIf cfg.enable {
    services = {
      # Use pipewire for audio.
      pipewire = {
        enable = true;

        pulse = {
          enable = true;
        };

        alsa = {
          enable = true;
        };

        wireplumber = {
          enable = true;
        };
      };

      pulseaudio = {
        enable = false;
      };
    };

    environment = {
      etc = {
        # Enable high quality bluetooth audio.
        "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
          bluez_monitor.properties = {
              ["bluez5.enable-sbc-xq"] = true,
              ["bluez5.enable-msbc"] = true,
              ["bluez5.enable-hw-volume"] = true,
              ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag a2dp_sink ]"
          }
        '';
      };
    };

    security = {
      # Enable realtime processing for hq audio.
      rtkit = {
        enable = true;
      };
    };
  };
}
