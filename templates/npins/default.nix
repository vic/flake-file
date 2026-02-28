let
  sources = import ./npins;
  with-inputs = import sources.with-inputs;

  locals ={
    # uncomment on CI for local checkout
    # flake-file = import ./../../modules;
  };

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = {
        inherit inputs;
        self = inputs.self;
      };
    }).config;
in
with-inputs sources locals outputs
