{ inputs, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
  ];

  systems = import inputs.systems;

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

}
