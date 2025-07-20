{ lib, ... }:
let
  follows-option = lib.mkOption {
    description = "flake input path to follow";
    default = "";
    type = lib.types.str;
  };

  inputs-follow-option = lib.mkOption {
    description = "input dependencies";
    default = { };
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          follows = follows-option;
          inputs = inputs-follow-option;
        };
      }
    );
  };

  inputs-option = lib.mkOption {
    default = { };
    description = "Flake inputs";
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          url = lib.mkOption {
            description = "source url";
            default = "";
            type = lib.types.str;
          };
          flake = lib.mkOption {
            description = "is it a flake?";
            type = lib.types.bool;
            default = true;
          };
          follows = follows-option;
          inputs = inputs-follow-option;
        };
      }
    );

  };

in
{
  options.flake-file.inputs = inputs-option;
}
