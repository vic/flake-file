flake-parts-path:
{ lib, ... }:
let
  imports = lib.flatten (parts ++ meta);

  parts = bootstrap.loadParts flake-parts-path;
  bootstrap = import ./_bootstrap.nix { inherit lib; };

  meta = lib.pipe "${flake-parts-path}/_meta" [
    bootstrap.loadParts
    (lib.map importMeta)
  ];

  importMeta = f: metaToConfig (import f);

  metaToConfig = meta: {
    flake-file = {
      inputs = if meta ? inputs then meta.inputs else { };
      nixConfig = {
        extraSubstituters = if meta ? extraSubstituters then meta.extraSubstituters else [ ];
        extraTrustedPublicKeys = if meta ? extraTrustedPublicKeys then meta.extraTrustedPublicKeys else [ ];
      };
    };
  };

in
{
  inherit imports;
}
