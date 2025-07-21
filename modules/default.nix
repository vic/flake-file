let
  flakeModules = {
    inherit
      default
      allfollow
      dendritic
      import-tree
      flake-parts-builder
      ;
  };

  default.imports = [
    ./options.nix
    ./write-flake.nix
  ];

  allfollow.imports = [ ./prune-lock/allfollow.nix ];

  import-tree.imports = [ ./import-tree.nix ];

  dendritic.imports = [ ./dendritic ];

  flake-parts-builder.imports = [ ./flake-parts-builder.nix ];

  templates.default = {
    description = "default template";
    path = ./../templates/default;
  };

  templates.dendritic = {
    description = "dendritic template";
    path = ./../templates/dendritic;
  };
in
{
  inherit flakeModules templates;
}
