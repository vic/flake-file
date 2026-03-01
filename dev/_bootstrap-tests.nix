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

  all-inputs-schemes = bootstrap {
    inputs.simple.url = "github:vic/empty-flake";
    inputs.withBranch.url = "github:vic/empty-flake/main";
    inputs.noflake = {
      url = "github:vic/empty-flake/main";
      flake = false;
    };
    inputs.gitHttps.url = "git+https://github.com/vic/empty-flake";
    inputs.tarball.url = "https://github.com/vic/empty-flake/archive/main.tar.gz";
    inputs.tarballPlus.url = "tarball+https://github.com/vic/empty-flake/archive/main.tar.gz";
    inputs.fileHttps.url = "file+https://github.com/vic/empty-flake/archive/main.tar.gz";
    inputs.attrGh = {
      type = "github";
      owner = "vic";
      repo = "empty-flake";
    };
    inputs.attrGhRef = {
      type = "github";
      owner = "vic";
      repo = "empty-flake";
      ref = "main";
    };
    inputs.followsSimple.follows = "simple";
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

  test-npins-schemes = pkgs.writeShellApplication {
    name = "test-npins-schemes";
    runtimeInputs = [
      (all-inputs-schemes.flake-file.apps.write-npins pkgs)
      pkgs.jq
    ];
    text = ''
      write-npins
      cat ${outdir}/npins/sources.json
      jq -e '.pins | has("simple")'      ${outdir}/npins/sources.json
      jq -e '.pins | has("withBranch")'  ${outdir}/npins/sources.json
      jq -e '.pins | has("noflake")'     ${outdir}/npins/sources.json
      jq -e '.pins | has("gitHttps")'    ${outdir}/npins/sources.json
      jq -e '.pins | has("tarball")'     ${outdir}/npins/sources.json
      jq -e '.pins | has("tarballPlus")' ${outdir}/npins/sources.json
      jq -e '.pins | has("fileHttps")'   ${outdir}/npins/sources.json
      jq -e '.pins | has("attrGh")'      ${outdir}/npins/sources.json
      jq -e '.pins | has("attrGhRef")'   ${outdir}/npins/sources.json
      jq -e '.pins | has("followsSimple") | not' ${outdir}/npins/sources.json
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
      grep empty ${outdir}/nixlock.lock.nix
    '';
  };

  test-write-lock-flake = pkgs.writeShellApplication {
    name = "test-write-lock-flake";
    runtimeInputs = [
      (empty.flake-file.apps.write-lock pkgs)
    ];
    text = ''
      echo "{ }" > ${outdir}/flake.lock
      write-lock
      [ -e ${outdir}/flake.nix ]
      grep github:vic/empty-flake ${outdir}/flake.nix
    '';
  };

  test-write-lock-npins = pkgs.writeShellApplication {
    name = "test-write-lock-npins";
    runtimeInputs = [
      (empty.flake-file.apps.write-lock pkgs)
      pkgs.jq
    ];
    text = ''
      mkdir -p ${outdir}/npins
      echo '{"pins":{},"version":7}' > ${outdir}/npins/sources.json
      write-lock
      jq -e '.pins | has("empty")' ${outdir}/npins/sources.json
    '';
  };

  test-write-lock-nixlock = pkgs.writeShellApplication {
    name = "test-write-lock-nixlock";
    runtimeInputs = [
      (empty.flake-file.apps.write-lock pkgs)
    ];
    text = ''
      echo '{ }' > ${outdir}/nixlock.lock.nix
      write-lock
      grep empty ${outdir}/nixlock.lock.nix
    '';
  };

  test-write-lock-unflake = pkgs.writeShellApplication {
    name = "test-write-lock-unflake";
    runtimeInputs = [
      (empty.flake-file.apps.write-lock pkgs)
    ];
    text = ''
      echo '{ }' > ${outdir}/unflake.nix
      write-lock --backend nix
      grep unflake_github_vic_empty-flake ${outdir}/unflake.nix
    '';
  };

  test-nixlock-schemes = pkgs.writeShellApplication {
    name = "test-nixlock-schemes";
    runtimeInputs = [
      (all-inputs-schemes.flake-file.apps.write-nixlock pkgs)
    ];
    text = ''
      write-nixlock
      cat ${outdir}/nixlock.lock.nix
      grep '"simple"' ${outdir}/nixlock.lock.nix
      grep '"withBranch"' ${outdir}/nixlock.lock.nix
      grep '"noflake"' ${outdir}/nixlock.lock.nix
      grep '"gitHttps"' ${outdir}/nixlock.lock.nix
      grep '"tarball"' ${outdir}/nixlock.lock.nix
      grep '"tarballPlus"' ${outdir}/nixlock.lock.nix
      grep '"fileHttps"' ${outdir}/nixlock.lock.nix
      grep '"attrGh"' ${outdir}/nixlock.lock.nix
      grep '"attrGhRef"' ${outdir}/nixlock.lock.nix
      if grep '"followsSimple"' ${outdir}/nixlock.lock.nix; then exit 1; fi
      grep vic/empty-flake ${outdir}/nixlock.lock.nix
    '';
  };

in
pkgs.mkShell {
  buildInputs = [
    test-inputs
    test-flake
    test-unflake
    test-npins
    test-npins-schemes
    test-npins-skip
    test-npins-follows
    test-npins-transitive
    test-nixlock
    test-nixlock-schemes
    test-write-lock-flake
    test-write-lock-npins
    test-write-lock-nixlock
    test-write-lock-unflake
  ];
}
