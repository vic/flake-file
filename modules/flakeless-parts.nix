{ config, lib, ... }:
{
  systems = lib.mkDefault lib.systems.flakeExposed;

  perSystem =
    { pkgs, ... }:
    {
      packages = lib.pipe config.flake-file.apps [
        (lib.filterAttrs (
          n: _:
          lib.elem n [
            "write-npins"
            "write-lock"
          ]
        ))
        (lib.mapAttrs (_: v: v pkgs))
      ];
    };
}
