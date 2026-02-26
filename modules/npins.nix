{ lib, config, ... }:
let
  inherit (config) flake-file;

  inherit (import ./../dev/modules/_lib lib) inputsExpr;

  inputs = inputsExpr flake-file.inputs;

  parseFlakeUrl =
    url:
    let
      parts = lib.splitString ":" url;
      scheme = lib.head parts;
      rest = lib.concatStringsSep ":" (lib.tail parts);
    in
    if scheme == "github" then
      parseGithub rest
    else if scheme == "gitlab" then
      parseGitlab rest
    else if isChannelUrl url then
      parseChannel url
    else if lib.hasPrefix "https://" url || lib.hasPrefix "http://" url then
      {
        type = "tarball";
        inherit url;
      }
    else
      {
        type = "git";
        inherit url;
      };

  parseGithub =
    rest:
    let
      segments = lib.splitString "/" rest;
      owner = lib.elemAt segments 0;
      repo = lib.elemAt segments 1;
      ref = if lib.length segments > 2 then lib.elemAt segments 2 else null;
    in
    {
      type = "github";
      inherit owner repo ref;
    };

  parseGitlab =
    rest:
    let
      segments = lib.splitString "/" rest;
      owner = lib.elemAt segments 0;
      repo = lib.elemAt segments 1;
      ref = if lib.length segments > 2 then lib.elemAt segments 2 else null;
    in
    {
      type = "gitlab";
      inherit owner repo ref;
    };

  isChannelUrl =
    url:
    lib.hasPrefix "https://channels.nixos.org/" url || lib.hasPrefix "https://releases.nixos.org/" url;

  parseChannel =
    url:
    let
      path = lib.removePrefix "https://channels.nixos.org/" url;
      channel = lib.head (lib.splitString "/" path);
    in
    {
      type = "channel";
      inherit channel;
    };

  branchFlag =
    parsed:
    if parsed ? ref && parsed.ref != null then " -b ${lib.escapeShellArg parsed.ref}" else " -b main";

  esc = lib.escapeShellArg;

  npinsAddCmd =
    name: parsed:
    if parsed.type == "github" then
      "npins add github --name ${esc name}${branchFlag parsed} ${esc parsed.owner} ${esc parsed.repo}"
    else if parsed.type == "gitlab" then
      "npins add gitlab --name ${esc name}${branchFlag parsed} ${esc parsed.owner} ${esc parsed.repo}"
    else if parsed.type == "channel" then
      "npins add channel --name ${esc name} ${esc parsed.channel}"
    else if parsed.type == "tarball" then
      "npins add tarball --name ${esc name} ${esc parsed.url}"
    else
      "npins add git --name ${esc name} ${esc parsed.url}";

  hasFollows = sub: sub ? follows && sub.follows != null;

  transitiveInputs =
    name: input:
    let
      subs = input.inputs or { };
      nonFollowed = lib.filterAttrs (_: sub: !(hasFollows sub)) subs;
    in
    lib.mapAttrs' (sub: _: lib.nameValuePair "${name}/${sub}" sub) nonFollowed;

  collectTransitive = lib.foldlAttrs (
    acc: name: input:
    acc // (transitiveInputs name input)
  ) { };

  pinnableInputs = lib.filterAttrs (_: v: v.url or "" != "") inputs;

  allTransitive = collectTransitive inputs;

  pinnableTransitive = lib.filterAttrs (_: v: v.url or "" != "") allTransitive;

  allPins = pinnableInputs // pinnableTransitive;

  addIfMissing =
    name: input:
    let
      cmd = npinsAddCmd name (parseFlakeUrl (input.url or ""));
    in
    ''
      if ! jq -e --arg n ${esc name} '.pins | has($n)' npins/sources.json >/dev/null 2>&1; then
        ${cmd} || (printf "\ncommand FAILED:\n    ${cmd}" >&2 && exit 1)
      fi
    '';

  addCommands = lib.concatStringsSep "\n" (lib.mapAttrsToList addIfMissing allPins);

  pinNames = lib.concatStringsSep " " (lib.attrNames allPins);

  write-npins =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-npins";
      runtimeInputs = [
        pkgs.npins
        pkgs.jq
      ];
      text = ''
        npins init --bare 2>/dev/null || true
        ${addCommands}
        wanted="${pinNames}"
        if [ -f npins/sources.json ]; then
          for existing in $(jq -r '.pins | keys[]' npins/sources.json); do
            keep=false
            for w in $wanted; do
              if [ "$existing" = "$w" ]; then keep=true; break; fi
            done
            if [ "$keep" = false ]; then
              npins remove "$existing"
            fi
          done
        fi
      '';
    };
in
{
  config.flake-file.apps = { inherit write-npins; };
}
