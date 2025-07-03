{
  perSystem =
    { pkgs, ... }:
    {
      packages.regen = pkgs.writeShellApplication {
        name = "regen";
        text = ''
          BASE="$PWD"
          function regen() {
            local wd="$1"
            pushd "$wd"
            nix run .#write-flake "''${@:2}"
            nix flake check "''${@:2}"
            popd
          }
          OPTS=("$@" --override-input flake-file "$BASE")
          regen templates/default "''${OPTS[@]}"
          regen templates/dendritic "''${OPTS[@]}"
          regen dev "''${OPTS[@]}"
        '';
      };
    };
}
