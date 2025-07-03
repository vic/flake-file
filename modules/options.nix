{ lib, ... }:
{
  options.flake-file = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule (
      { ... }:
      {
        config.auto-follow.enable = lib.mkDefault true;
        options = {
          auto-follow.enable = lib.mkEnableOption "Flatten the lock file using fzakaria/nix-auto-follow";
          auto-follow.pkg = lib.mkOption {
            description = "nix-auto-follow package. should take `-i` or `-c`.";
            type = lib.types.nullOr lib.types.package;
            default = null;
          };
          do-not-edit = lib.mkOption {
            default = ''
              # DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
              # Use `nix run .#write-flake` to regenerate it.
            '';
            description = "header comment";
            type = lib.types.str;
            apply =
              value:
              lib.pipe value [
                (s: if lib.hasPrefix "#" s then s else "# " + s)
                (s: if lib.hasSuffix "\n" s then s else s + "\n")
              ];
            example = lib.literalExample ''
              "DO-NOT-EDIT"
            '';
          };
          formatter = lib.mkOption {
            description = ''
              Formatter for flake.nix file.

              It is a function fron pkgs to a shell command (string).

              The command takes flake.nix as first argument.
            '';
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
            description = ''
              Nix code for outputs function.

              We recommend this function code to be short, used only to import a file.
            '';
            type = lib.types.str;
            default = ''
              inputs: import ./outputs.nix inputs
            '';
            example = lib.literalExample ''
              inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./module
            '';
          };
          inputs = lib.mkOption {
            default = { };
            description = "Flake inputs";
            type = lib.types.lazyAttrsOf (
              lib.types.submodule (
                { ... }:
                {
                  options = {
                    url = lib.mkOption {
                      description = "source url";
                      type = lib.types.str;
                    };
                    flake = lib.mkOption {
                      description = "is it a flake?";
                      type = lib.types.bool;
                      default = true;
                    };
                    follows = lib.mkOption {
                      description = "input dependencies follows";
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
