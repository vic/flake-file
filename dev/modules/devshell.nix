{ inputs, ... }:
{
  flake-file.inputs.devshell.url = "github:numtide/devshell";

  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem =
    { pkgs, self', ... }:
    {
      devshells.default.commands = [
        {
          help = "regen all flake.nix on this repo";
          package = self'.packages.regen;
        }
        {
          help = "run a command on each sub flake";
          package = self'.packages.each;
        }
        {
          name = "fmt";
          help = "format all files in repo";
          command = "nix run ./dev#fmt --override-input flake-file .";
        }
        {
          name = "update";
          help = "update all flakes and prune locks";
          command = ''
            ${pkgs.lib.getExe self'.packages.each} nix run .#write-flake
            ${pkgs.lib.getExe self'.packages.each} nix flake update
            ${pkgs.lib.getExe self'.packages.each} nix run .#write-flake
          '';
        }
        {
          name = "check";
          help = "run flake check";
          command = "nix flake check ./dev --override-input flake-file .";
        }
      ];
    };
}
