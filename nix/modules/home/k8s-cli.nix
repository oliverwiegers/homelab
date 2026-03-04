{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.terminal.programs.k8s-cli;
in
{
  imports = [
    inputs.krewfile.homeManagerModules.krewfile
  ];

  options.terminal.programs.k8s-cli = {
    enable = lib.mkEnableOption "Enable k8s cli tools.";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Kubectl. Plugins are managed down below using krewfile.
      kubectl

      # helm
      (wrapHelm kubernetes-helm {
        plugins = with kubernetes-helmPlugins; [
          helm-secrets
          helm-s3
        ];
      })

      # Misc tools
      # Checkout home-manager module: https://github.com/nix-community/home-manager/pull/5929
      # Completions might not work yet.
      kubecolor
      k9s
      kdash
      s3cmd

      # OS specific tools
      talosctl
    ];

    programs = {
      krewfile = {
        enable = true;
        krewPackage = pkgs.krew;
        plugins = [
          "allctx"
          "cost"
          "ctr"
          "ctx"
          "df-pv"
          "explore"
          "krew"
          "ktop"
          "neat"
          "ns"
          "tree"
          "stern"
          "view-allocations"
          "view-cert"
          "view-secret"
          "view-utilization"
        ];
      };

      zsh = lib.mkIf config.terminal.shell.zsh.enable {
        # Making kubectl completions work even if kubecolor is used.
        initContent = "source <(kubectl completion zsh | sed 's/kubectl/kubecolor/g')";

        shellAliases = {
          kubectl = "kubecolor";
          kk = "kubectl krew";
          kns = "kubectl ns";
          kcon = "kubectl ctx";
        };

        oh-my-zsh = {
          plugins = [
            "kubectl"
            "helm"
          ];
        };
      };
    };
  };
}
