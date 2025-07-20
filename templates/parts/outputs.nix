inputs:
inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  imports = [
    inputs.flake-file.flakeModules.default
    (inputs.flake-file.lib.flakeModules.flake-parts-builder ./flake-parts)
  ];
}
