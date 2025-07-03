{ inputs, ... }:
{

  imports = [
    inputs.files.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    files.url = "github:mightyiam/files";
  };
}
