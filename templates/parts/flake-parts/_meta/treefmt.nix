{
  description = "Bindings for the treefmt formatter and a basic treefmt configuration.";

  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  dependencies = [ "flake-root" ];
  #extraTrustedPublicKeys = [ "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE=" ];
  #extraSubstituters = [ "https://numtide.cachix.org" ];
}
