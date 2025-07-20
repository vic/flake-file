{ inputs, lib, ... }:
{

  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.import-tree
  ];

  flake.modules = { };

  flake-file.inputs = {
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules)
  '';

}
