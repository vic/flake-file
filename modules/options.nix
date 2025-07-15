{ lib, ... }:
let
  outputs-option = lib.mkOption {
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
    apply =
      inputs:
      if inputs ? allfollow then (import ./allfollow.nix lib).add-allfollow-input inputs else inputs;
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

  do-not-edit-option = lib.mkOption {
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

  formatter-option = lib.mkOption {
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

  flake-file-option = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule (
      { ... }:
      {
        options = {
          do-not-edit = do-not-edit-option;
          formatter = formatter-option;
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
          outputs = outputs-option;
          inputs = inputs-option;
        };
      }
    );

  };

in
{
  options.flake-file = flake-file-option;
}
