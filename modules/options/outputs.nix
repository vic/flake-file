{ lib, ... }:
{
  options.flake-file.outputs = lib.mkOption {
    description = ''
      Nix code for outputs function.

      We recommend this function code to be short, used only to import a file.
    '';
    type = lib.types.str;
    default = ''
      inputs: import ./outputs.nix inputs
    '';
    example = lib.literalExample ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./modules
    '';
  };
}
