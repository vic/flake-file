{ config, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = lib.mapAttrs (_: f: f pkgs) config.flake-file.apps;
      checks.check-flake-file = config.flake-file.check-flake-file pkgs;
    };
}
