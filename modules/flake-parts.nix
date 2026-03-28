{ config, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      apps = lib.mapAttrs (_: f: { program = f pkgs; }) config.flake-file.apps;
      checks.check-flake-file = config.flake-file.check-flake-file pkgs;
    };
}
