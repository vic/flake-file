{ lib, config, ... }:
let
  inherit (config) flake-file;
  inherit (import ../lib.nix lib) inputsExpr;

  inputs = inputsExpr flake-file.inputs;

  nixlock-source = fetchTarball {
    url = flake-file.nixlock.url;
    sha256 = flake-file.nixlock.sha256;
  };

  nlLibs = (import "${nixlock-source}/${flake-file.nixlock.version}").libs;

  parseGithub =
    path:
    let
      parts = lib.splitString "/" path;
      owner = builtins.elemAt parts 0;
      repo = builtins.elemAt parts 1;
      ref = if builtins.length parts > 2 then builtins.elemAt parts 2 else "HEAD";
    in
    {
      type = "gitArchive";
      url = "https://github.com/${owner}/${repo}";
      inherit ref;
    };

  parseGitlab =
    path:
    let
      parts = lib.splitString "/" path;
      owner = builtins.elemAt parts 0;
      repo = builtins.elemAt parts 1;
      ref = if builtins.length parts > 2 then builtins.elemAt parts 2 else "HEAD";
    in
    {
      type = "gitArchive";
      url = "https://gitlab.com/${owner}/${repo}";
      inherit ref;
    };

  flakeUrlToNixlock =
    url:
    let
      scheme = builtins.head (lib.splitString ":" url);
      rest = lib.concatStringsSep ":" (builtins.tail (lib.splitString ":" url));
    in
    if scheme == "github" then
      parseGithub rest
    else if scheme == "gitlab" then
      parseGitlab rest
    else if lib.hasPrefix "git+" url then
      {
        type = "git";
        url = lib.removePrefix "git+" url;
        ref = "HEAD";
      }
    else if lib.hasPrefix "http" url then
      {
        type = "archive";
        inherit url;
      }
    else
      null;

  toNixlockInput = _name: input: if input ? url then flakeUrlToNixlock input.url else null;

  inputsFile = lib.filterAttrs (_: v: v != null) (lib.mapAttrs toNixlockInput inputs);

  lockListFor =
    upType: lockFile:
    lib.filterAttrs (
      name: value:
      !(lockFile ? ${name})
      || value != lockFile.${name}.meta or { }
      || (if upType == "update" then !(value.isFreeze or false) else false)
    ) inputsFile;

  shellFor =
    upType: lockFile: lockFileName:
    let
      entries = lockListFor upType lockFile;
    in
    nlLibs.toLockShell {
      inherit lockFile lockFileName;
      inputsFile = entries;
      cmds = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (n: v: nlLibs.types.${v.type}.fresh n v) entries
      );
    };

  write-nixlock =
    pkgs:
    let
      rootPath = flake-file.intoPath;
      lockFileName = flake-file.nixlock.lockFileName;
      lockScript = shellFor "lock" { } lockFileName;
      updateScript = shellFor "update" { } lockFileName;
    in
    pkgs.writeShellApplication {
      name = "write-nixlock";
      excludeShellChecks = [
        "SC2016"
        "SC2086"
        "SC2089"
        "SC2090"
      ];
      runtimeInputs = with pkgs; [
        nix
        nixfmt
        git
        nix-prefetch-git
        curl
        coreutils
        gnugrep
        gnused
        gawk
        jq
      ];
      text = ''
        cd ${rootPath}
        case "''${1:-lock}" in
          lock)   ${lockScript}   ;;
          update) ${updateScript} ;;
          *) echo "usage: write-nixlock [lock|update]" >&2; exit 1 ;;
        esac
      '';
    };
in
{
  config.flake-file.apps = { inherit write-nixlock; };
  options.flake-file.nixlock = {
    url = lib.mkOption {
      type = lib.types.str;
      description = "nixlock archive url";
      default = "https://codeberg.org/FrdrCkII/nixlock/archive/dad9155634ce5d5183429daaeef2bbf6de9afcbf.tar.gz";
    };
    sha256 = lib.mkOption {
      type = lib.types.str;
      description = "nixlock archive sha256";
      default = "sha256:0bycgfdar1xcxgbp75r7bpmfvm2qh8206q2h2vsx5qn8fr39x0li";
    };
    version = lib.mkOption {
      type = lib.types.str;
      description = "nixlock version to load";
      default = "v3";
    };
    lockFileName = lib.mkOption {
      type = lib.types.str;
      description = "nixlock lockfile name";
      default = "nixlock.lock.nix";
    };
  };
}
