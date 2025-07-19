# Example pruning app that does nothing.
pkgs:
pkgs.writeShellApplication {
  name = "cp";
  text = ''
    cp "$1" "$2"
  '';
}
