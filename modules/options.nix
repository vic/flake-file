{ lib, ... }:
{
  options.flake-file = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule (
      { ... }:
      {
        options = {
          description = lib.mkOption {
            default = "";
            description = "Flake description";
            type = lib.types.str;
          };
          nixConfig = lib.mkOption {
            default = { };
            description = "nix config";
            type = lib.types.attrs;
          };
          outputs = lib.mkOption {
            description = "nix code for outputs function";
            type = lib.types.str;
            default = ''
              inputs: import ./outputs.nix inputs
            '';
          };
          inputs = lib.mkOption {
            default = { };
            description = "Flake inputs";
            type = lib.types.lazyAttrsOf (
              lib.types.submodule (
                { name, ... }:
                {
                  options = {
                    url = lib.mkOption {
                      description = "${name} url";
                      type = lib.types.str;
                    };
                    flake = lib.mkOption {
                      description = "is ${name} a flake?";
                      type = lib.types.bool;
                      default = true;
                    };
                    follows = lib.mkOption {
                      description = "${name} inputs follows";
                      default = { };
                      type = lib.types.lazyAttrsOf lib.types.str; # TODO: type.oneOf flake.input.names
                    };
                  };
                }
              )
            );
          };
        };
      }
    );
  };
}
