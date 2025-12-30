{ inputs, lib, ... }:
{

  imports = [
    (inputs.flake-parts.flakeModules.modules or { })
    (inputs.flake-file.flakeModules.import-tree or { })
  ];

  flake-file.inputs = {
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = lib.mkDefault "nixpkgs-lib";
  };

  flake-file.outputs = lib.mkDefault ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
  '';

  flake.modules = { };

}
