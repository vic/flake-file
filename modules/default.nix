let
  default = {
    imports = [
      ./options.nix
      ./write-flake.nix
    ];
  };

  dendritic = {
    imports = [
      default
      ./dendritic.nix
    ];
  };
in
{
  flakeModules = {
    inherit default dendritic;
  };
  templates.default = {
    description = "default template";
    path = ./../templates/default;
  };
  templates.dendritic = {
    description = "dendritic template";
    path = ./../templates/dendritic;
  };
}
