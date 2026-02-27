let
  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;

  input-overrides = {
    # uncomment for local checkout on CI
    # flake-file = import ./../../modules;
  };

  with-inputs = import (fetchTarball {
    url = "https://github.com/vic/with-inputs/archive/f19ccc093928f4987ab56534e0de37b25d8f5817.zip";
    sha256 = "sha256:0bcfic6myy2qmyj40kxpxv04hp925l9b0wkd507v69d070qsg285";
  });

  nixlock-inputs = builtins.mapAttrs (
    _n: v:
    v
    // {
      outPath = fetchTarball {
        url = v.lock.url;
        sha256 = v.lock.hash;
      };
    }
  ) (import ./nixlock.lock.nix);
in
with-inputs nixlock-inputs input-overrides outputs
