{ lib, ... }:
{
  flake-file.inputs.import-tree.url = lib.mkDefault "github:vic/import-tree";
}
