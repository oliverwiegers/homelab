{
  lib,
  pkgs,
  inputs,
  config,
  ...
}:
let
  cfg = config.terminal.programs.rust;
in
{
  options.terminal.programs.rust = {
    enable = lib.mkEnableOption "Enable Rust lang toolchains.";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.fenix.overlays.default ];
    home.packages = with pkgs; [
      (inputs.fenix.packages.${system}.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      rust-analyzer-nightly
    ];
  };
}
