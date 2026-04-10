{ config, lib, ... }:
{
  systems = lib.mkDefault lib.systems.flakeExposed;

  perSystem =
    { pkgs, ... }:
    {
      apps.write-npins = {
        program = config.flake-file.apps.write-npins pkgs;
      };
    };
}
