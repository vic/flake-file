{ inputs, lib, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = lib.mkDefault "github:vic/flake-file";
  };
}
