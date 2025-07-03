{ inputs, lib, ... }:
{

  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  flake.modules = { };

  flake-file.inputs = {
    import-tree.url = lib.mkDefault "github:vic/import-tree";
    flake-parts.url = lib.mkDefault "github:hercules-ci/flake-parts";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules)
  '';

}
