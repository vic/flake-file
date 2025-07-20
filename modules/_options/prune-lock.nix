{ lib, ... }:
lib.mkOption {
  default = { };
  type = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "Should we automatically prune flake.lock";
      program = lib.mkOption {
        description = ''
          Function from pkgs to an exe derivation used to prune flake.lock.

          The program takes the flake.lock location as first positional argument
          and is expected to produce a pruned version into the second argument.

          The output is expected to be deterministic.
        '';
        example = lib.literalExample (builtins.readFile ./../prune-lock/_nothing.nix);
        type = lib.types.functionTo lib.types.unspecified;
        default = import ./../prune-lock/_nothing.nix;
      };
    };
  };
}
