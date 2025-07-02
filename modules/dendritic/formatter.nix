{ inputs, ... }:
{

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.follows = {
      nixpkgs = "nixpkgs";
    };
  };

  perSystem =
    { self', ... }:
    {
      packages.fmt = self'.formatter;
      treefmt = {
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
