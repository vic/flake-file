{ lib, config, ... }:
let
  inherit (config) flake-file;
  inherit (import ./../dev/modules/_lib lib) inputsExpr;

  inputs = inputsExpr flake-file.inputs;
  esc = lib.escapeShellArg;

  inherit (import ./inputs-lib.nix lib esc inputs)
    followsSeed
    queueSeed
    ;

  write-deps =
    pkgs:
    let
      normalizeNix = pkgs.writeText "normalize.nix" (builtins.readFile ./deps/normalize.nix);
    in
    pkgs.writeShellApplication {
      name = "write-deps";
      runtimeInputs = [
        pkgs.curl
        pkgs.jq
        pkgs.nix
        pkgs.git
      ];
      text = ''
        cd ${flake-file.intoPath}

        ${builtins.readFile ./deps/url.bash}
        ${builtins.readFile ./deps/fetch-forge.bash}
        ${builtins.readFile ./deps/fetch.bash}
        ${builtins.readFile ./deps/bfs.bash}

        FOLLOWS_FILE=$(mktemp)
        SEEN_FILE=$(mktemp)
        QUEUE_FILE=$(mktemp)
        DEPS_FILE=$(mktemp)
        NORMALIZE_NIX=${normalizeNix}
        trap 'rm -f "$FOLLOWS_FILE" "$SEEN_FILE" "$QUEUE_FILE" "$DEPS_FILE"' EXIT

        ${followsSeed}
        ${queueSeed}

        bfs_main
        write_deps_nix
      '';
    };
in
{
  config.flake-file.apps = { inherit write-deps; };
}
