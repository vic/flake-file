{
  # inputs,
  lib,
  config,
  ...
}:
{
  options.dendritic.devshell.enable = lib.mkOption {
    description = "Enable numtide/devshell";
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.dendritic.devshell.enable {

    # imports = [ inputs.devshell.flakeModule ];

    flake-file.inputs.devshell.url = "github:numtide/devshell";

  };
}
