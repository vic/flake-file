{ lib, ... }:
let

  # TODO: Extensible flake output schema!
  outputsType = lib.types.submodule {
    freeformType = lib.types.lazyAttrsOf lib.types.unspecified;
  };

in
{
  imports = [
    (lib.mkAliasOptionModule [ "inputs" ] [ "flake-file" "inputs" ])
  ];

  options.outputs = lib.mkOption {
    type = lib.type.functionTo outputsType;
  };
}
