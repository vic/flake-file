let
  default = {
    imports = [
      ./options.nix
      ./write-flake.nix
    ];
  };

  allfollow = {
    imports = [
      ./allfollow.nix
    ];
  };

  dendritic = {
    imports = [
      default
      allfollow
      ./dendritic.nix
    ];
  };
in
{
  flakeModules = {
    inherit default allfollow dendritic;
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
