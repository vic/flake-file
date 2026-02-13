let

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;

  withInputs =
    inputs: outputs:
    outputs (
      inputs
      // {
        # uncomment to use local checkout on CI
        # flake-file = import ./../../modules;
      }
    );

in
(import ./unflake.nix withInputs) outputs
