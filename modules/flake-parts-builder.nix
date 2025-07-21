{ inputs, lib, ... }:
let
  imports = [
    meta
    defaults
    non-defaults
    inputs.flake-file.flakeModules.import-tree
  ];

  # transforms parts meta.nix into flake.nix config values.
  metaToConfig = meta: {
    flake-file = {
      inherit (meta) inputs;
      nixConfig = {
        inherit (meta) extraSubstituters extraTrustedPublicKeys;
      };
    };
  };

  fp = inputs.import-tree.addPath "./flake-parts";

  meta = lib.pipe fp [
    (i: i.filter (lib.hasInfix "/flake-parts/meta/"))
    (i: i.map import)
    (i: i.map metaToConfig)
  ];

  defaults = fp.filter (lib.hasSuffix "default.nix");

  non-defaults = fp.filter noDefaultDominated;

  noDefaultDominated = p: (lib.filesystem.locateDominatingFile "default.nix" p) == null;
in
{
  inherit imports;
}
