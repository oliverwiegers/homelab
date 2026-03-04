{
  # config,
  inputs,
  flake,
  ...
}:
let
  host = baseNameOf ./.;
  inherit (flake.lib._metadata.hosts.${host}) hostId;
in
{
  imports = builtins.concatLists [
    (builtins.attrValues flake.modules.nixos)

    [
      "${flake}/nix/profiles/nix-settings.nix"
      "${flake}/nix/profiles/acme-defaults.nix"
      "${flake}/nix/profiles/sops-defaults.nix"

      inputs.sops-nix.nixosModules.sops
    ]
  ];

  #    ______           __                     __  ___          __      __
  #   / ____/_  _______/ /_____  ____ ___     /  |/  /___  ____/ /_  __/ /__  _____
  #  / /   / / / / ___/ __/ __ \/ __ `__ \   / /|_/ / __ \/ __  / / / / / _ \/ ___/
  # / /___/ /_/ (__  ) /_/ /_/ / / / / / /  / /  / / /_/ / /_/ / /_/ / /  __(__  )
  # \____/\__,_/____/\__/\____/_/ /_/ /_/  /_/  /_/\____/\__,_/\__,_/_/\___/____/

  base.stateVersion = "25.11";

  zfsRoot = {
    enable = true;
    inherit hostId;
  };

  # tailscale = {
  #   enable = true;
  #   authKeyFile = config.sops.secrets."headscale/preauthkey".path;
  # };

  serverBase = {
    enable = true;
  };

  # consul = {
  #   enable = true;
  #   type = "server";
  #   bindAddr = "100.64.0.1";
  #   uiBindAddr = "100.64.0.1";
  #   clientSecretsFile = "${flake}/secrets.yaml";
  #   serverSecretsFile = ./secrets.yaml;
  # };

  #     _   ___      ____  _____
  #    / | / (_)  __/ __ \/ ___/
  #   /  |/ / / |/_/ / / /\__ \
  #  / /|  / />  </ /_/ /___/ /
  # /_/ |_/_/_/|_|\____//____/

  #   ________    _          __   ____             __
  #  /_  __/ /_  (_)________/ /  / __ \____ ______/ /___  __
  #   / / / __ \/ / ___/ __  /  / /_/ / __ `/ ___/ __/ / / /
  #  / / / / / / / /  / /_/ /  / ____/ /_/ / /  / /_/ /_/ /
  # /_/ /_/ /_/_/_/   \__,_/  /_/    \__,_/_/   \__/\__, /
  #                                                /____/

  # sops = {
  #   defaultSopsFile = ./secrets.yaml;

  #   secrets = {
  #     "headscale/preauthkey" = { };
  #   };
  # };
}
