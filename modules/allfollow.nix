{ lib, inputs, ... }:
{
  flake-file.inputs.allfollow.url = "github:spikespaz/allfollow";
  flake-file.prune-lock.enable = lib.mkDefault true;
  flake-file.prune-lock.command =
    pkgs: "${pkgs.lib.getExe inputs.allfollow.packages.${pkgs.system}.default} prune --pretty -o -";
}
