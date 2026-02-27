{ lib, ... }:
{
  flake-file.inputs = {
    import-tree.url = lib.mkDefault "github:vic/import-tree";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    nixpkgs.url = lib.mkDefault "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
