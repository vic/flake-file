# DO-NOT-EDIT. This file was auto-generated.
{
  inputs = {
    files = {
      url = "github:mightyiam/files";
    };
    flake-file = {
      url = "github:vic/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    systems = {
      url = "github:nix-systems/default";
    };
  };
  outputs = inputs: import ./outputs.nix inputs;
}
