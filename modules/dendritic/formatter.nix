{ inputs, lib, ... }:
{

  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    treefmt-nix.url = lib.mkDefault "github:numtide/treefmt-nix";
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
        settings.on-unmatched = lib.mkDefault "fatal";
        settings.global.excludes = [
          "LICENSE"
          "flake.lock"
          "**/flake.lock"
          ".envrc"
        ];
      };
    };

}
