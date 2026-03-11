{ lib, config, ... }:
let
  inherit (config) flake-file;
  inherit (import ../lib.nix lib) inputsExpr;

  inputs = flake-file.nixlock.preProcess (inputsExpr flake-file.inputs);

  nixlock-source = fetchTarball {
    url = flake-file.nixlock.url;
    sha256 = flake-file.nixlock.sha256;
  };

  nl = import "${nixlock-source}/${flake-file.nixlock.version}" flake-file.nixlock.customTypes;
  inherit (nl.nllib)
    lockFileStart
    lockFileEnd
    lockFileMerge
    getFetcher
    withInputs
    ;
  types = nl.types;

  inherit (import ./parse.nix lib) toNixlockInput;

  inputsFile = lib.filterAttrs (_: v: v != null) (lib.mapAttrs toNixlockInput inputs);

  lockFilePath = "${flake-file.intoPath}/${flake-file.nixlock.lockFileName}";
  existingLock =
    if lib.hasPrefix "/" lockFilePath && builtins.pathExists lockFilePath then
      import lockFilePath
    else
      { };

  sources = existingLock: withInputs fetchedInputs existingLock;

  cmdFor =
    name: v:
    if existingLock ? ${name} then
      lockFileMerge {
        inherit name;
        meta = v;
        lock = existingLock.${name}.lock;
      }
    else
      types.${v.type}.update name v;

  scriptWith = cmds: lockFileName: ''
    ${lockFileStart}
    ${lib.concatStringsSep "\n" cmds}
    ${lockFileEnd}
    echo $LOCKFILE | nixfmt > '${lockFileName}'
  '';

  lockScript =
    lockFileName:
    scriptWith (lib.mapAttrsToList (n: v: types.${v.type}.update n v) inputsFile) lockFileName;

  updateScript =
    lockFileName:
    scriptWith (lib.mapAttrsToList (
      n: v: if v.isFreeze or false then cmdFor n v else types.${v.type}.update n v
    ) inputsFile) lockFileName;

  updateOneScript =
    target: lockFileName:
    scriptWith (lib.mapAttrsToList (
      n: v: if n == target then types.${v.type}.update n v else cmdFor n v
    ) inputsFile) lockFileName;

  perInputCases =
    lockFileName:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: _: ''
        ${name}) ${updateOneScript name lockFileName} ;;
      '') inputsFile
    );

  fetchedInputs = lib.mapAttrs (
    _name: entry:
    getFetcher {
      rootPath = flake-file.intoPath;
      inherit (entry) meta lock;
      type = "stable";
    }
  ) existingLock;

  write-nixlock =
    pkgs:
    let
      rootPath = flake-file.intoPath;
      lockFileName = flake-file.nixlock.lockFileName;
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
          lock)
            ${lockScript lockFileName}
            ;;
          update)
            case "''${2:-}" in
              "")
                ${updateScript lockFileName}
                ;;
              ${perInputCases lockFileName}
              *) echo "unknown input: ''${2}" >&2; exit 1 ;;
            esac
            ;;
          *) echo "usage: write-nixlock [lock|update [<input>]]" >&2; exit 1 ;;
        esac
      '';
    };
in
{
  config = {
    flake-file.apps = { inherit write-nixlock; };
  };
  options.flake-file.nixlock = {
    url = lib.mkOption {
      type = lib.types.str;
      description = "nixlock archive url";
      default = "https://codeberg.org/FrdrCkII/nixlock/archive/fc10414fc2a2db7ad5daeeaa9e92e0e139102f9f.tar.gz";
    };
    sha256 = lib.mkOption {
      type = lib.types.str;
      description = "nixlock archive sha256";
      default = "sha256:0zqxki955iizglm5qs7gp914p7vsv7wjdabx053nk9maba7zpdja";
    };
    version = lib.mkOption {
      type = lib.types.str;
      description = "nixlock version to load";
      default = "v3.1";
    };
    lockFileName = lib.mkOption {
      type = lib.types.str;
      description = "nixlock lockfile name";
      default = "nixlock.lock.nix";
    };
    sources = lib.mkOption {
      type = lib.types.functionTo lib.types.unspecified;
      readOnly = true;
      description = "Fetched inputs from the nixlock lockfile via withInputs, ready to use as flake inputs.";
      default = sources;
    };
    customTypes = lib.mkOption {
      type = lib.types.raw;
      description = "nixlock custom input types";
      default = { };
    };
    preProcess = lib.mkOption {
      type = lib.types.functionTo lib.types.raw;
      description = "Pre-process flake-file inputs before giving to nixlock";
      default = lib.id;
    };
  };
}
