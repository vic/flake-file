let
  outputs =
    inputs:
    let
      nixpkgs = inputs.nixpkgs or (import <nixpkgs> { });
      import-tree = inputs.import-tree or (import <import-tree>);
    in
    (nixpkgs.lib.evalModules {
      modules = [ (import-tree ./modules) ];
      specialArgs = {
        inherit inputs;
        self = inputs.self or { };
      };
    }).config;

  withInputs =
    inputs: outputs:
    outputs (
      inputs
      // {
        # uncomment on CI for local checkout
        # flake-file = import ./../../modules;
      }
    );
in
import ./with-inputs.nix withInputs outputs
