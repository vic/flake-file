{ inputs, ... }:
{

  imports = [
    inputs.flake-parts.flakeModules.modules
  ];

  flake-file.inputs = {
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules)
  '';

}
