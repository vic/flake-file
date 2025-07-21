{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.flake-file.flakeModules.import-tree
    inputs.flake-file.flakeModules.allfollow
    ./dendritic.nix
    ./basic.nix
    ./formatter.nix
    ./nixpkgs.nix
    ./systems.nix
  ];
}
