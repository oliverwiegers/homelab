{
  pkgs,
  lib,
  ...
}:
let
  unstablePackages = with pkgs; [
    erdtree
    eza
    findutils
    gnumake
    gnused
    go
    jq
    ncdu
    neofetch
    nerd-fonts.sauce-code-pro
    nerd-fonts.iosevka
    pass
    pre-commit
    pywal
    ranger
    ripgrep
    testssl
    urlscan
    watch
    tree
    android-tools
    nh
  ];

  inputsOverlayPackages = with pkgs.inputs; [
    flim.flim
  ];
in
{
  options = {
    os = {
      theme = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "kanagawa";
        };
        variant = lib.mkOption {
          type = lib.types.str;
          default = "wave";
        };
        fullName = lib.mkOption {
          type = lib.types.str;
          default = null;
        };
        colors = lib.mkOption {
          type = lib.types.attrs;
          default = null;
        };
      };
    };
  };

  config = {
    home.packages = unstablePackages ++ inputsOverlayPackages;
  };
}
