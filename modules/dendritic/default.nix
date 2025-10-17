{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    inputs.flake-file.flakeModules.nix-auto-follow
    ./dendritic.nix
    ./basic.nix
    ./formatter.nix
    ./nixpkgs.nix
    ./systems.nix
  ];
}
