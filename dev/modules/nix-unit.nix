{ inputs, ... }:
{
  flake-file.inputs.nix-unit.url = "github:nix-community/nix-unit";
  flake-file.inputs.nix-unit.inputs.flake-parts.follows = "flake-parts";

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
