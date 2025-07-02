{
  flakeModules.default = {
    imports = [
      ./options.nix
      ./files.nix
    ];
  };
  flakeModules.dendritic = {
    imports = [
      ./options.nix
      ./files.nix
      ./dendritic
    ];
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
