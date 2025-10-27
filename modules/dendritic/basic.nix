{ inputs, lib, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    inputs.flake-file.flakeModules.nix-auto-follow
  ];

  flake-file.inputs = {
    flake-file.url = lib.mkDefault "github:vic/flake-file";
  };
}
