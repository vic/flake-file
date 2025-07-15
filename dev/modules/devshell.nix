{ inputs, ... }:
{
  flake-file.inputs.devshell.url = "github:numtide/devshell";

  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem =
    { self', ... }:
    {
      devshells.default.commands = [
        {
          help = "regen all flake.nix on this repo";
          package = self'.packages.regen;
        }
        {
          name = "fmt";
          help = "format all files in repo";
          command = "nix run ./dev#fmt --override-input flake-file .";
        }
        {
          name = "check";
          help = "run flake check";
          command = "nix flake check ./dev --override-input flake-file .";
        }
      ];
    };
}
