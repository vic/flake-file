{ inputs, lib, ... }:
{

  imports = [
    (inputs.flake-parts.flakeModules.modules or { })
    (inputs.flake-file.flakeModules.import-tree or { })
    (inputs.flake-aspects.flakeModule or { })
  ];

  flake-file.inputs = {
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
    flake-aspects.url = lib.mkDefault "github:vic/flake-aspects";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules)
  '';

}
