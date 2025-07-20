{
  description = "Sets up the default `systems` of flake-parts using `github:nix-systems/default`.";

  inputs = {
    systems.url = "github:nix-systems/default";
  };

  extraTrustedPublicKeys = [ ];
  extraSubstituters = [ ];
}
