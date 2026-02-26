{ lib, config, ... }:
let
  outputsOption = lib.mkOption { type = lib.type.functionTo outputsType; };

  outputsType = lib.types.submoduleWith {
    modules = [
      { freeformType = lib.types.lazyAttrsOf lib.types.unspecified; }
      config.flake-file.outputs-schema
    ];
  };

  # Extensible flake output schema!
  outputsSchemaOption = lib.mkOption {
    type = lib.types.deferredModule;
    default = { };
  };
in
{
  imports = [
    (lib.mkAliasOptionModule [ "inputs" ] [ "flake-file" "inputs" ])
    (lib.mkAliasOptionModule [ "description" ] [ "flake-file" "description" ])
    (lib.mkAliasOptionModule [ "nixConfig" ] [ "flake-file" "nixConfig" ])
  ];

  options.outputs = outputsOption;
  options.flake-file.outputs-schema = outputsSchemaOption;
}
