{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      exe = name: pkgs.lib.getExe inputs.self.packages.${pkgs.system}.${name};
      puke = exe "puke";
      oneach = exe "oneach";
      each = exe "each";
    in
    {
      packages.oneach = pkgs.writeShellApplication {
        name = "oneach";
        text = ''
          (
            pushd "$1"
            # shellcheck disable=SC2068
            ''${@:2}
            popd
          )
        '';
      };

      packages.each = pkgs.writeShellApplication {
        name = "each";
        text = ''
          set -e -o pipefail
          find . -mindepth 2 -name flake.nix -print0 | xargs -0 -n 1 dirname | xargs -n 1 -I FLAKE_DIR ${oneach} FLAKE_DIR "$@"
        '';
      };

      packages.puke = pkgs.writeShellApplication {
        name = "puke";
        text = ''
          set -e
          nix run .#write-flake "$@"
          nix flake check "$@"
        '';
      };

      packages.regen = pkgs.writeShellApplication {
        name = "regen";
        text = ''
          ${each} ${puke} --override-input flake-file "$PWD"
        '';
      };
    };
}
