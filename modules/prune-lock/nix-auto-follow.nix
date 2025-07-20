{ lib, inputs, ... }:
{
  flake-file.inputs.nix-auto-follow.url = lib.mkDefault "github:fzakaria/nix-auto-follow";
  flake-file.prune-lock.enable = lib.mkDefault (inputs ? nix-auto-follow);
  flake-file.prune-lock.program =
    pkgs:
    pkgs.writeShellApplication {
      name = "nix-auto-follow";
      runtimeInputs = [ inputs.nix-auto-follow.packages.${pkgs.system}.default ];
      text = ''
        auto-follow "$1" > "$2"
      '';
    };
}
