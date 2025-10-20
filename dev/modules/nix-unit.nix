{ inputs, ... }:
{
  flake-file.inputs.nix-unit = {
    url = "github:nix-community/nix-unit";
    inputs.flake-parts.follows = "flake-parts";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.treefmt-nix.follows = "treefmt-nix";
  };

  imports = [ inputs.nix-unit.modules.flake.default ];

  perSystem.nix-unit = {
    inherit inputs;
    allowNetwork = true;
  };

  flake.tests.testTruth = {
    expr = true;
    expected = true;
  };
}
