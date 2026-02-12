{ lib, ... }:
{

  flake-file.inputs = {
    nixpkgs.url = lib.mkDefault "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    nixpkgs-lib.follows = lib.mkDefault "nixpkgs";
  };

}
