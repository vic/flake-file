let
  with-inputs = import sources.with-inputs sources {
    # uncomment for local checkout on CI
    # flake-file = import ./../../modules;
  };

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs = { inherit inputs; };
    }).config;

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
in
with-inputs outputs
