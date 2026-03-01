{ inputs, ... }:
{
  imports = [ inputs.flake-file.flakeModules.unflake ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    with-inputs.url = "github:vic/with-inputs";
    with-inputs.flake = false;
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
}
