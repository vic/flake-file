let
  with-inputs = import sources.with-inputs;
  locals = {
    # uncomment for local checkout on CI
    # flake-file = import ./../../modules;
  };

  sources = builtins.mapAttrs (
    _n: v:
    v
    // {
      outPath = fetchTarball {
        url = v.lock.url;
        sha256 = v.lock.hash;
      };
    }
  ) (import ./nixlock.lock.nix);

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;
in
with-inputs sources locals outputs
