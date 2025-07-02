{
  flakeModules.default = {
    imports = [
      ./options.nix
      ./files.nix
    ];
  };
  templates.default = {
    description = "default template";
    path = ./../templates/default;
  };
}
