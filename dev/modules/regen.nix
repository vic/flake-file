{
  perSystem =
    { pkgs, ... }:
    {
      packages.regen = pkgs.writeShellApplication {
        name = "regen";
        text = ''
          function regen() {
            local wd="$1"
            pushd "$wd"
            git init
            git add .
            nix run .#write-files "''${@:2}"
            rm -rf .git
            popd
          }
          OPTS=("$@" --override-input flake-file "$PWD")
          regen templates/default "''${OPTS[@]}"
          regen templates/dendritic "''${OPTS[@]}"
          regen dev "''${OPTS[@]}"
        '';
      };
    };
}
