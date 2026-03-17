{
  pkgs,
  perSystem,
}:
perSystem.devshell.mkShell {
  # Add build dependencies
  packages = with pkgs; [
    git
    pre-commit
    ruby
    deadnix
    statix
    flake-checker
    deploy-rs
    sops
    wget
    nixos-anywhere
    ssh-to-age

    # Terraform
    opentofu
    tflint
    terraform-docs
    s3cmd
  ];

  env = [
    {
      name = "NIXPKGS_ALLOW_UNFREE";
      value = 1;
    }
  ];
}
