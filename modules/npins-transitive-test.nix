{ lib, ... }:
{
  # Declares neomacs with nixpkgs-follows so nixpkgs is not re-pinned separately.
  # Transitive discovery must find crane, rust-overlay, nix-wpe-webkit
  # from neomacs's own flake.nix at runtime.
  flake-file.inputs = {
    nixpkgs.url = lib.mkDefault "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
    neomacs = {
      url = "github:eval-exec/neomacs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
