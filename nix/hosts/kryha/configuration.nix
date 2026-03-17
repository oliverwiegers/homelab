{
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
    device = "/dev/vda";
  };

  # tailscale = {
  #   enable = true;
  #   authKeyFile = config.sops.secrets."headscale/preauthkey".path;
  # };

  # monitoring = {
  #   enable = false;
  # };

  serverBase = {
    enable = true;

    fancyMotd.extraServices = ''
      services["kanidm"]="Kanidm"
    '';
  };

  # consul = {
  #   enable = true;
  #   type = "server";
  #   bindAddr = "100.64.0.4";
  #   uiBindAddr = "100.64.0.4";
  #   clientSecretsFile = "${flake}/secrets.yaml";
  #   serverSecretsFile = ./secrets.yaml;
  # };

  #     _   ___      ____  _____
  #    / | / (_)  __/ __ \/ ___/
  #   /  |/ / / |/_/ / / /\__ \
  #  / /|  / />  </ /_/ /___/ /
  # /_/ |_/_/_/|_|\____//____/

  # systemd.services.kanidm.wants = [ "acme-${authFQDN}.service" ];

  # services = {
  #   kanidm =
  #     let
  #       certDir = config.security.acme.certs.${authFQDN}.directory;
  #     in
  #     {
  #       enableServer = true;
  #       enableClient = true;
  #       clientSettings.uri = "${authURI}:8443";
  #       package = pkgs.kanidmWithSecretProvisioning;

  #       serverSettings = {
  #         tls_key = certDir + "/key.pem";
  #         tls_chain = certDir + "/fullchain.pem";
  #         origin = authURI;
  #         ldapbindaddress = "127.0.0.1:636";
  #         domain = authFQDN;

  #         online_backup = {
  #           versions = 1;
  #           path = "/var/backup/kanidm";
  #         };
  #       };

  #       provision = {
  #         enable = true;
  #         idmAdminPasswordFile = config.sops.secrets."kanidm/idm_admin".path;
  #         adminPasswordFile = config.sops.secrets."kanidm/admin".path;
  #       };
  #     };
  # };

  # # While not externally exposed we'll use this.
  # networking.hosts = {
  #   "127.0.0.1" = [ "auth.oliverwiegers.com" ];
  # };

  # security.acme.certs."${authFQDN}" = { };

  # users.groups.certs.members = [ "kanidm" ];

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
  #     "kanidm/admin".owner = "kanidm";
  #     "kanidm/idm_admin".owner = "kanidm";
  #   };
  # };
}
