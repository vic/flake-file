{
  pkgs ? import <nixpkgs> { },
  modules ? [ ],
  outdir ? ".",
  bootstrap ? true,
  import-tree ? (
    pkgs.fetchFromGitHub {
      owner = "vic";
      repo = "import-tree";
      rev = "c968d3b54d12cf5d9c13f16f7c545a06c9d1fde6";
      hash = "sha256-oYO4poyw0Sb/db2PigqugMlDwsvwLg6CSpFrMUWxA3Q=";
    }
  ),
  ...
}:
let
  inherit (pkgs) lib;

  tree = (import import-tree) modules;

  attrsOpt = lib.mkOption {
    default = { };
    type = lib.types.submodule { freeformType = lib.types.lazyAttrsOf lib.types.unspecified; };
  };

  module = {
    imports = [
      tree
      ./modules
      ./modules/options
      ./modules/npins.nix
      ./modules/unflake.nix
      ./modules/write-inputs.nix
      ./modules/write-flake.nix
      ./modules/flake-options.nix
      (if bootstrap then ./modules/bootstrap.nix else { })
    ];
    config.flake-file.intoPath = outdir;
    options = {
      lib = attrsOpt;
      templates = attrsOpt;
      flakeModules = attrsOpt;
    };
  };

  outputs =
    (lib.evalModules {
      modules = [ module ];
      specialArgs.inputs.self.outPath = "";
    }).config;

in
outputs
