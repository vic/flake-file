{ inputs, ... }:
{

  flake-file.inputs = {
    systems.url = "github:nix-systems/default";
  };

  systems = import inputs.systems;

}
