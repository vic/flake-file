{
  pkgs ? import <nixpkgs> { },
  outdir ? "bootstrap-tests",
  ...
}@args:
let
  # determine the list of available test names by importing once (outdir irrelevant)
  names = map (x: x.name) (import ./_bootstrap-tests.nix args).buildInputs;

  # for each name we re-import the test definitions with a unique outdir
  perTests = map (
    name:
    let
      shellFor = import ./_bootstrap-tests.nix (args // { outdir = "${outdir}/${name}"; });
      matches = builtins.filter (x: x.name == name) shellFor.buildInputs;
    in
    builtins.head matches
  ) names;

  # create a single shell application that runs every named test in parallel
  test-all = pkgs.writeShellApplication {
    name = "test-all";
    runtimeInputs = perTests;
    text = ''
      set -euo pipefail

      # build a space-separated list of test names supplied by Nix
      names="${pkgs.lib.concatStringsSep " " names}"

      # pmap will record pid:name pairs so we can identify failures later
      pmap=""

      for name in $names; do
        rm -rf "${outdir}/$name"
        mkdir -p "${outdir}/$name"
        (
          set -v
          echo "Boostrap $name"
          "$name" >&2> "${outdir}/$name/output.log"
        ) &
        pid=$!
        pmap="$pmap $pid:$name"
      done

      failures=""
      for entry in $pmap; do
        pid="''${entry%%:*}"
        name="''${entry#*:}"
        echo -n "Waiting for $name"
        if wait "$pid"; then
          echo " [SUCCEED]"
        else
          echo " [FAILED]"
          failures="$failures $name"
        fi
      done

      if [ -n "$failures" ]; then
        echo "FAILURES: $failures"
        for name in $failures; do
          echo "=== $name ==="
          cat "${outdir}/$name/output.log" || true
          echo
        done
        exit 1
      fi
    '';
  };
in
pkgs.mkShell {
  buildInputs = [ test-all ];
}
