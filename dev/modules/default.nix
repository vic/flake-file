{ inputs, ... }:
{

  imports = [
    inputs.files.flakeModules.default
    inputs.flake-file.flakeModules.default
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    files.url = "github:mightyiam/files";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.follows = {
      nixpkgs = "nixpkgs";
    };
  };

  systems = import inputs.systems;
  perSystem =
    { config, self', ... }:
    {
      packages.write-files = config.files.writer.drv;
      packages.fmt = self'.formatter;
      treefmt = {
        projectRoot = inputs.flake-file;
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          nixf-diagnose.enable = true;
          prettier.enable = true;
        };
        settings.on-unmatched = "fatal";
        settings.global.excludes = [
          "LICENSE"
        ];
      };
    };

}
