_inputs: {
  flakeModules.default = {
    imports = [
      ./modules/options.nix
      ./modules/files.nix
    ];
  };
  templates.default = {
    description = "default template";
    path = ./templates/default;
  };
}
