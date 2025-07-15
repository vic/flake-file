lib:
let
  merge-missing =
    from: into:
    lib.pipe into (
      lib.mapAttrsToList (
        name: value: into:
        if into ? ${name} then into else into // { ${name} = value; }
      ) from
    );

  new-input = url: follows: {
    inherit url;
    flake = true;
    inputs = lib.mapAttrs (_: follows: {
      inherit follows;
    }) follows;
  };

  add-allfollow-input = merge-missing {
    nixpkgs = new-input "github:nixos/nixpkgs/nixpkgs-unstable" { };
    rust-overlay = new-input "github:oxalica/rust-overlay" {
      nixpkgs = "nixpkgs";
    };
    systems = new-input "github:nix-systems/default" { };
    allfollow = new-input "github:spikespaz/allfollow" {
      nixpkgs = "nixpkgs";
      rust-overlay = "rust-overlay";
      systems = "systems";
    };
  };

  runner =
    { pkgs, inputs', ... }:
    if inputs' ? allfollow then
      pkgs.writeShellApplication {
        name = "allfollow-run";
        runtimeInputs = [
          pkgs.nix
          pkgs.delta
          inputs'.allfollow.packages.default
        ];
        text = ''
          set -e
          if [ "apply" == "$1" ]; then
            nix flake lock
            allfollow prune --pretty flake.lock --in-place
          fi
          if [ "check" == "$1" ]; then
            allfollow prune --pretty "$2" -o pruned.lock
            delta --paging never pruned.lock "$2"
          fi
        '';
      }
    else
      pkgs.writeShellApplication {
        name = "nothing";
        text = "true";
      };

in
{
  inherit add-allfollow-input runner;
}
