{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.terminal.programs.terraform;
in
{
  options.terminal.programs.terraform = {
    enable = lib.mkEnableOption "Enable Terraform.";
    default = false;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      terraform
      tflint
      terraform-docs
      terragrunt
      s3cmd
      opentofu
    ];

    programs = {
      zsh = lib.mkIf config.terminal.shell.zsh.enable {
        oh-my-zsh = {
          plugins = [
            "terraform"
            "opentofu"
          ];
        };
      };
    };
  };
}
