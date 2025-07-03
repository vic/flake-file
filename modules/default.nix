{
  flakeModules.default = {
    imports = [
      ./options.nix
      ./files.nix
      ./write-files.nix
    ];
  };
  flakeModules.dendritic = {
    imports = [
      ./options.nix
      ./files.nix
      ./write-files.nix
      ./dendritic.nix
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
