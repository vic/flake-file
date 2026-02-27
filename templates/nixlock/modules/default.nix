{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.nixlock ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
  };
}
