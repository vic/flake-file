{ lib, ... }:
{
  options.flake-file = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule (
      { ... }:
      {
        options = {
          do-not-edit = lib.mkOption {
            default = ''
              # DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
              # Use `nix run .#write-files` to regenerate it.
            '';
            description = "comment header. it must start with #.";
            type = lib.types.str;
          };
          formatter = lib.mkOption {
            description = "Function from pkgs to flake.nix formatter. Takes flake.nix as first argument.";
            type = lib.types.functionTo lib.types.str;
            default = pkgs: pkgs.lib.getExe pkgs.nixfmt-rfc-style;
            example = lib.literalExample ''
              pkgs: pkgs.lib.getExe pkgs.nixfmt-rfc-style
            '';
          };
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
