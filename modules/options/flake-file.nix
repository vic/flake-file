{ lib, ... }:
{
  options.flake-file = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule {
      options = {
        description = lib.mkOption {
          default = "";
          description = "Flake description";
          type = lib.types.str;
        };
        nixConfig = lib.mkOption {
          default = { };
          description = "nix config";
          type = lib.types.attrsOf lib.types.anything;
        };
      };
    };
  };
}
