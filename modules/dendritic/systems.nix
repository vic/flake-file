{ inputs, lib, ... }:
{

  flake-file.inputs = {
    systems.url = lib.mkDefault "github:nix-systems/default";
  };

  systems = lib.mkDefault (import inputs.systems);

}
