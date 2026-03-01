let
  sources = import ./unflake.nix;
  with-inputs = import sources.with-inputs sources {
    # uncomment to use local checkout on CI
    # flake-file = import ./../../modules;
  };

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;
in
with-inputs outputs
