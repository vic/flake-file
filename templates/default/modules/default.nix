{ inputs, ... }:
{

  imports = [
    inputs.files.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    files.url = "github:mightyiam/files";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  systems = import inputs.systems;
  perSystem =
    { config, ... }:
    {
      packages.write-files = config.files.writer.drv;
    };

}
