{
  blueprint,
  ...
}@inputs:
blueprint {
  inherit inputs;
  prefix = "/nix";
  nixpkgs.config.allowUnfree = true;
  # We don't have any other systems.
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
}
