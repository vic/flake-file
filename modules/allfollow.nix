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
    inherit url follows;
    flake = true;
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
    enabled:
    { pkgs, inputs', ... }:
    if enabled then
      pkgs.writeShellApplication {
        name = "allfollow-run";
        runtimeInputs = [
          pkgs.nix
          pkgs.difftastic
          pkgs.jq
          inputs'.allfollow.packages.default
        ];
        text = ''
          if [ "apply" == "''${1:-}" ]; then
            nix flake lock
            allfollow prune --pretty "''${2}" -o - | jq -S . > flake.lock.pruned
            mv flake.lock.pruned "''${2}"
          fi
          if [ "check" == "''${1:-}" ]; then
            allfollow prune "''${2}" --pretty -o pruned.lock
            allfollow count --json --pretty -o - pruned.lock | jq -S . > pruned.json
            allfollow count --json --pretty -o - "''${2}" | jq -S . > current.json
            difft --exit-code --display inline pruned.json current.json
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
