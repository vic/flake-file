{
  pkgs ? import <nixpkgs> { },
  modules ? [ ],
  outdir ? ".",
  bootstrap ? [ ],
  outputs ? null,
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

  bootstrapInputs =
    let
      ins = import ./inputs.nix { inherit lib; };
      take = name: { flake-file.inputs.${name} = ins.flake-file.inputs.${name}; };
      names =
        if bootstrap == true then lib.attrNames ins.flake-file.inputs else lib.flatten [ bootstrap ];
    in
    map take names;

  module = {
    imports = [
      tree
      ./../default.nix
      ./../options
      ./../npins
      ./../unflake
      ./../write-inputs.nix
      ./../write-flake.nix
      ./../flake-options.nix
      { imports = bootstrapInputs; }
      (if outputs == null then { } else { flake-file.outputs = outputs; })
    ];
    config.flake-file.intoPath = outdir;
    options = {
      lib = attrsOpt;
      templates = attrsOpt;
      flakeModules = attrsOpt;
    };
  };

  evaled = lib.evalModules {
    modules = [ module ];
    specialArgs.inputs.self.outPath = "";
  };

in
evaled.config
