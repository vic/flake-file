# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  inputs = {
    flake-file = {
      url = "github:vic/flake-file";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    systems = {
      url = "github:nix-systems/default";
    };
    treefmt-nix = {
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
      url = "github:numtide/treefmt-nix";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
