{ inputs, ... }:
{
  flake-file.inputs.nix-unit.url = "github:nix-community/nix-unit";

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
