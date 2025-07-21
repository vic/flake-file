let
  flakeModules = {
    inherit
      default
      allfollow
      nix-auto-follow
      dendritic
      import-tree
      ;
  };

  default.imports = [
    ./options.nix
    ./write-flake.nix
  ];

  allfollow.imports = [ ./prune-lock/allfollow.nix ];

  nix-auto-follow.imports = [ ./prune-lock/nix-auto-follow.nix ];

  import-tree.imports = [ ./import-tree.nix ];

  dendritic.imports = [ ./dendritic ];

  lib.flakeModules.flake-parts-builder =
    path:
    { flake-parts-lib, ... }:
    {
      imports = [
        (flake-parts-lib.importApply ./flake-parts-builder path)
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

  templates.parts = {
    description = "flake-parts-builder template";
    path = ./../templates/parts;
  };
in
{
  inherit flakeModules templates lib;
}
