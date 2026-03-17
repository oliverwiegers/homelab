{
  pkgs,
  inputs,
  ...
}:
inputs.treefmt-nix.lib.mkWrapper pkgs {
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    deadnix.enable = true;
    prettier.enable = true;
    statix.enable = true;
    hclfmt.enable = true;
    terraform.enable = true;
    shellcheck.enable = true;
    shfmt = {
      enable = true;
      indent_size = 4;
    };
  };

  settings = {
    verbose = 1;

    global.excludes = [
      "LICENSE"
      # unsupported extensions
      "*.{gif,png,svg,tape,mts,lock,mod,sum,toml,env,envrc,gitignore,pages}"
      "etc/ssh_public_keys/*"
      "image_bakery/etc/id_ed25519_deploy_key"
      "terraform/etc/talos/*.yaml"
      "*/templates/*.yaml"
      "k8s/apps/*/charts/*"
    ];

    formatter = {
      deadnix = {
        priority = 1;
      };

      statix = {
        priority = 2;
      };

      nixfmt = {
        priority = 3;
        excludes = [ "nix/templates/*" ];
      };

      prettier = {
        includes = [ "*.{css,html,js,json,jsx,md,mdx,scss,ts,yaml}" ];
      };

      shfmt = {
        includes = [ "etc/scripts/*" ];
      };
    };
  };
}
