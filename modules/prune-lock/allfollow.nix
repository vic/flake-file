{ lib, inputs, ... }:
{
  flake-file.inputs.allfollow.url = lib.mkDefault "github:spikespaz/allfollow";
  flake-file.prune-lock.enable = lib.mkDefault (inputs ? allfollow);
  flake-file.prune-lock.program =
    pkgs:
    pkgs.writeShellApplication {
      name = "allfollow";
      runtimeInputs = [ inputs.allfollow.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      text = ''
        allfollow prune --pretty "$1" -o "$2"
      '';
    };
}
