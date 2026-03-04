{
  inputs,
  flake,
  ...
}: {
  imports = builtins.concatLists [
    (builtins.attrValues flake.modules.nixos)

    [
      ./hardware.nix
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-gpu-amd
    ]
  ];

  #    ______           __                     __  ___          __      __
  #   / ____/_  _______/ /_____  ____ ___     /  |/  /___  ____/ /_  __/ /__  _____
  #  / /   / / / / ___/ __/ __ \/ __ `__ \   / /|_/ / __ \/ __  / / / / / _ \/ ___/
  # / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /  / / /_/ / /_/ / /_/ / /  __(__  )
  # \____/\__,_/____/\__/\____/_/ /_/ /_/  /_/  /_/\____/\__,_/\__,_/_/\___/____/

  workstation = {
    enable = true;

    audio = flake.lib.enabled;
    bluetooth = flake.lib.enabled;
    laptop = flake.lib.enabled;
    virtualization = flake.lib.enabled;
    wifi = flake.lib.enabled;
    wm = flake.lib.enabled;
  };

  base.stateVersion = "23.11";

  #     _   ___      ____  _____
  #    / | / (_)  __/ __ \/ ___/
  #   /  |/ / / |/_/ / / /\__ \
  #  / /|  / />  </ /_/ /___/ /
  # /_/ |_/_/_/|_|\____//____/

  networking = {
    wireless = {
      enable = true;
      interfaces = [ "wlp3s0" ];

      networks = {
        Follow-The-Wires-5ghz = {
          pskRaw = "21e2dd18b60e3b63ab9d0eaa30f6e1e54f88df7b52785bfa9aadb0c720e9c224";
        };
        WIFIonICE = { };
        "Motel One Guest Wi-Fi" = { };
      };
    };
  };
}
