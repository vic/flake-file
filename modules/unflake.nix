{ lib, config, ... }:
let
  inherit (config) flake-file;

  write-unflake =
    pkgs:
    pkgs.writeShellApplication {
      name = "write-unflake";
      text = ''
        cd ${flake-file.intoPath}
        nix-shell "${flake-file.unflake.url}" -A unflake-shell --run "unflake -i ${flake-file.inputsFile pkgs} $*"
      '';
    };
in
{
  config.flake-file.apps = { inherit write-unflake; };
  options.flake-file.unflake = {
    url = lib.mkOption {
      type = lib.types.str;
      description = "unflake archive url";
      default = "https://codeberg.org/goldstein/unflake/archive/main.tar.gz";
    };
  };
}
