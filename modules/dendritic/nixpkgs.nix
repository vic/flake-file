{ lib, ... }:
{

  flake-file.inputs = {
    nixpkgs.url = lib.mkDefault "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.follows = "nixpkgs";
  };

}
