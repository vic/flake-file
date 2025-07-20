{ lib, ... }:
let
  flake-file-option = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule {
      options = flake-options // {
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
      };
    };
  };

  flake-options =
    lib.pipe
      [
        "inputs"
        "outputs"
        "do-not-edit"
        "formatter"
        "prune-lock"
      ]
      [
        (map (n: {
          ${n} = import ./_options/${n}.nix { inherit lib; };
        }))
        lib.mergeAttrsList
      ];

in
{
  options.flake-file = flake-file-option;
}
