{ inputs, lib, ... }:
{

  imports = [
    inputs.files.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    files.url = lib.mkDefault "github:mightyiam/files";
  };
}
