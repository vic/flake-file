let
  flakeModules = {
    inherit
      default
      allfollow
      nix-auto-follow
      dendritic
      import-tree
      npins
      deps
      unflake
      flake-options
      ;
  };

  flake-options = ./flake-options.nix;

  base.imports = [
    ./options
    ./write-inputs.nix
  ];

  npins.imports = [
    base
    ./npins.nix
  ];

  deps.imports = [
    base
    ./deps.nix
  ];

  unflake.imports = [
    base
    ./unflake.nix
  ];

  default.imports = [
    base
    ./write-flake.nix
    ./flake-parts.nix
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

  templates.npins = {
    description = "npins template";
    path = ./../templates/npins;
  };

  templates.unflake = {
    description = "unflake template";
    path = ./../templates/unflake;
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
