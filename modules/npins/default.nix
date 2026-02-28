{ lib, config, ... }:
let
  inherit (config) flake-file;
  inherit (import ../lib.nix lib) inputsExpr;

  inputs = inputsExpr flake-file.inputs;

  # Synthesise a canonical URL from attrset-form inputs (no url field).
  gitHostScheme = { github = "github"; gitlab = "gitlab"; sourcehut = "sourcehut"; };

  syntheticUrl = input:
    let
      scheme = gitHostScheme.${input.type or ""} or null;
      ref = if input.ref or "" != "" then "/${input.ref}" else "";
    in
    if scheme != null && input.owner or "" != "" then
      "${scheme}:${input.owner}/${input.repo or ""}${ref}"
    else
      null;

  inputUrl = input:
    if input.url or "" != "" then input.url
    else syntheticUrl input;

  pinnableInputs = lib.filterAttrs (_: input: inputUrl input != null) inputs;

  # Seed the runtime queue with one tab-separated "name\turl" line per declared input.
  queueSeed =
    lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: input: "${name}\t${inputUrl input}") pinnableInputs);

  # Collect names of inputs that are explicitly skipped (follows = "") at any nesting level.
  collectSkipped =
    inputMap:
    lib.concatLists (
      lib.mapAttrsToList (
        name: input:
        let
          here = lib.optional (input ? follows && input.follows == "") name;
          nested = if input ? inputs then collectSkipped input.inputs else [ ];
        in
        here ++ nested
      ) inputMap
    );

  skipSet = lib.concatStringsSep "\n" (collectSkipped inputs);

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
        inherit queueSeed skipSet;
      };
      text = builtins.readFile ./npins.bash;
    };
in
{
  config.flake-file.apps = { inherit write-npins; };
}
