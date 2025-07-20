{ lib, ... }:
let
  description = ''
    Hooks to run on .#write-flake

    Ordered by their index field before being run.
    Run on the working copy, so any changes will be
    seen by version control.
  '';
  hook = lib.types.submodule {
    options = {
      # we use this as poor-man's DAG.
      index = lib.mkOption {
        description = "Index of this hook to run. For user hooks use >100.";
        type = lib.types.int;
        default = 100;
      };
      program = lib.mkOption {
        description = ''
          Function from pkgs to program (package with meta.mainProgram).
        '';
        type = lib.types.functionTo lib.types.unspecified;
      };
    };
  };

in
{
  options.flake-file.write-hooks = lib.mkOption {
    inherit description;
    default = [ ];
    type = lib.types.listOf hook;
  };

}
