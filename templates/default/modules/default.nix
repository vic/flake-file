{ inputs, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
  ];

  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };

}
