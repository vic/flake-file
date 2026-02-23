{ lib, ... }:
{
  systems = lib.mkDefault lib.systems.flakeExposed;
}
