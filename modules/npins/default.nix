{ lib, config, ... }:
let
  inherit (config) flake-file;
  inherit (import ../lib.nix lib) inputsExpr;

  inputs = inputsExpr flake-file.inputs;
  esc = lib.escapeShellArg;

  pinnableInputs = lib.filterAttrs (_: v: v.url or "" != "") inputs;

  # Seed the runtime queue with one tab-separated "name\turl" line per declared input.
  queueSeed =
    let
      lines = lib.mapAttrsToList (name: input: "${name}\t${input.url or ""}") pinnableInputs;
    in lib.concatStringsSep "\n" lines;

  write-npins =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-npins";
      runtimeInputs = [
        pkgs.npins
        pkgs.jq
        pkgs.curl
        pkgs.nix
      ];
      runtimeEnv = {
        out = flake-file.intoPath;
        inherit queueSeed;
      };
      text = builtins.readFile ./npins.bash;
    };
in
{
  config.flake-file.apps = { inherit write-npins; };
}
