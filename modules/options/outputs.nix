{ lib, ... }:
let
  easyOutputs = {
    default = ''
      inputs: import ./outputs.nix inputs
    '';

    flake-file = ''
      inputs: (import ./flake-file.nix).outputs inputs
    '';

    flake-module = ''
      inputs:
        (inputs.nixpkgs.lib.evalModules {
          specialArgs = { inherit inputs; inherit (inputs) self; };
          modules = [ ./flake-file.nix ];
        }).config.outputs inputs
    '';

    import-tree = ''
      inputs:
      (inputs.nixpkgs.lib.evalModules {
        specialArgs = { inherit inputs; inherit (inputs) self; };
        modules = [ (import-tree ./modules) ];
      }).config.outputs inputs
    '';

    flake-parts = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } ./modules
    '';

    dendritic = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
    '';
  };
in
{
  options.flake-file.outputs = lib.mkOption {
    description = ''
      Nix code for outputs function.

      We recommend this function code to be short, used only to import a file.
    '';
    type = lib.types.str;
    default = "default";
    apply = output: easyOutputs.${output} or output;
    example = lib.literalExample easyOutputs.dendritic;
  };
}
