let
  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = {
        inherit inputs;
        self = inputs.self;
      };
    }).config;

  with-inputs = import (builtins.fetchTarball {
    url = "https://github.com/vic/with-inputs/archive/f19ccc093928f4987ab56534e0de37b25d8f5817.zip";
    sha256 = "sha256:0bcfic6myy2qmyj40kxpxv04hp925l9b0wkd507v69d070qsg285";
  });

  inputs-overrides ={
    # uncomment on CI for local checkout
    # flake-file = import ./../../modules;
  };

  sources = import ./npins;
in
with-inputs sources inputs-overrides outputs
