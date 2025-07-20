{ lib, ... }:
lib.mkOption {
  description = ''
    Formatter for flake.nix file.

    It is a function from pkgs to a shell command (string).

    The command takes flake.nix as first argument.
  '';
  type = lib.types.functionTo lib.types.str;
  default = pkgs: pkgs.lib.getExe pkgs.nixfmt-rfc-style;
  example = lib.literalExample ''
    pkgs: pkgs.lib.getExe pkgs.nixfmt-rfc-style
  '';
}
