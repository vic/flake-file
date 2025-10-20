{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.dendritic ];
  flake-file.inputs.flake-file.url = "path:..";
}
