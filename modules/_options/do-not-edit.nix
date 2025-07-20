{ lib, ... }:
lib.mkOption {
  default = ''
    # DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
    # Use `nix run .#write-flake` to regenerate it.
  '';
  description = "header comment";
  type = lib.types.str;
  apply =
    value:
    lib.pipe value [
      (s: if lib.hasPrefix "#" s then s else "# " + s)
      (s: if lib.hasSuffix "\n" s then s else s + "\n")
    ];
  example = lib.literalExample ''
    "DO-NOT-EDIT"
  '';
}
