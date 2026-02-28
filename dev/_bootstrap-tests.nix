{
  pkgs ? import <nixpkgs> { },
  outdir ? ".",
  ...
}@args:
let

  bootstrap =
    modules:
    import ./.. (
      args
      // {
        inherit modules;
      }
    );

  empty = bootstrap {
    inputs.empty.url = "github:vic/empty-flake";
    outputs = _: { };
  };

  flake-parts = bootstrap {
    inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  };

  flake-parts-follows = bootstrap {
    inputs.nixpkgs-lib.url = "github:vic/empty-flake";
    inputs.flake-parts.url = "github:hercules-ci/flake-parts";
    inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";
  };

  flake-parts-skip = bootstrap {
    inputs.flake-parts.url = "github:hercules-ci/flake-parts";
    inputs.flake-parts.inputs.nixpkgs-lib.follows = "";
  };

  test-inputs = pkgs.writeShellApplication {
    name = "test-inputs";
    runtimeInputs = [
      (empty.flake-file.apps.write-inputs pkgs)
    ];
    text = ''
      write-inputs
      cat ${outdir}/inputs.nix
      grep github:vic/empty-flake ${outdir}/inputs.nix
    '';
  };

  test-flake = pkgs.writeShellApplication {
    name = "test-flake";
    runtimeInputs = [
      pkgs.nix
      (empty.flake-file.apps.write-flake pkgs)
    ];
    text = ''
      write-flake
      cat ${outdir}/flake.nix
      grep github:vic/empty-flake ${outdir}/flake.nix
    '';
  };

  test-npins = pkgs.writeShellApplication {
    name = "test-npins";
    runtimeInputs = [
      (empty.flake-file.apps.write-npins pkgs)
      pkgs.jq
    ];
    text = ''
      write-npins
      cat ${outdir}/npins/sources.json
      jq -e '.pins | has("empty")' ${outdir}/npins/sources.json
    '';
  };

  test-npins-transitive = pkgs.writeShellApplication {
    name = "test-npins-transitive";
    runtimeInputs = [
      (flake-parts.flake-file.apps.write-npins pkgs)
      pkgs.jq
    ];
    text = ''
      write-npins
      cat ${outdir}/npins/sources.json
      jq -e '.pins."flake-parts".url | contains("hercules-ci/flake-parts")' ${outdir}/npins/sources.json
      jq -e '.pins."nixpkgs-lib".url | contains("nix-community/nixpkgs.lib")' ${outdir}/npins/sources.json
    '';
  };

  test-npins-follows = pkgs.writeShellApplication {
    name = "test-npins-follows";
    runtimeInputs = [
      (flake-parts-follows.flake-file.apps.write-npins pkgs)
      pkgs.jq
    ];
    text = ''
      write-npins
      cat ${outdir}/npins/sources.json
      jq -e '.pins."flake-parts".url | contains("hercules-ci/flake-parts")' ${outdir}/npins/sources.json
      jq -e '.pins."nixpkgs-lib".url | contains("vic/empty")' ${outdir}/npins/sources.json
    '';
  };

  test-npins-skip = pkgs.writeShellApplication {
    name = "test-npins-skip";
    runtimeInputs = [
      (flake-parts-skip.flake-file.apps.write-npins pkgs)
      pkgs.jq
    ];
    text = ''
      write-npins
      cat ${outdir}/npins/sources.json
      jq -e '.pins."flake-parts".url | contains("hercules-ci/flake-parts")' ${outdir}/npins/sources.json
      jq -e '.pins | has("nixpkgs-lib") | not' ${outdir}/npins/sources.json
    '';
  };

  test-unflake = pkgs.writeShellApplication {
    name = "test-unflake";
    runtimeInputs = [
      (empty.flake-file.apps.write-unflake pkgs)
    ];
    text = ''
      write-unflake --backend nix
      grep unflake_github_vic_empty-flake ${outdir}/unflake.nix
    '';
  };

  test-nixlock = pkgs.writeShellApplication {
    name = "test-nixlock";
    runtimeInputs = [
      (empty.flake-file.apps.write-nixlock pkgs)
    ];
    text = ''
      write-nixlock
      grep vic/empty-flake/archive ${outdir}/nixlock.lock.nix
    '';
  };

in
pkgs.mkShell {
  buildInputs = [
    test-inputs
    test-flake
    test-unflake
    test-npins
    test-npins-skip
    test-npins-follows
    test-npins-transitive
    test-nixlock
  ];
}
