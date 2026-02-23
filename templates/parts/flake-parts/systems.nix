# --- flake-parts/systems.nix
{ inputs, ... }:
{
  # NOTE We use the default `systems` defined by `nixpkgs`, if
  # you need any additional systems, simply add them in the following manner
  #
  # `systems = (inputs.nixpkgs.lib.systems.flakeExposed) ++ [ "armv7l-linux" ];`
  systems = inputs.nixpkgs.lib.systems.flakeExposed;
}
