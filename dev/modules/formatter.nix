{ inputs, ... }:
{
  perSystem.treefmt.projectRoot = inputs.flake-file;
}
