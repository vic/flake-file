{ lib, ... }:
{
  options.flake-file = lib.mkOption {
    description = "A nix flake.";
    default = { };
    type = lib.types.submodule {
      options = {
        description = lib.mkOption {
          default = "";
          description = "Flake description";
          type = lib.types.str;
        };
        nixConfig = lib.mkOption {
          default = { };
          description = "nix config";
          type = lib.types.submodule {
            freeformType = lib.types.attrsOf lib.types.anything;

            options = {
              substituters = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = ''
                  List of binary cache URLs used to obtain pre-built binaries
                  of Nix packages.
                '';
              };

              extra-substituters = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = ''
                  List of binary cache URLs used to obtain pre-built binaries
                  of Nix packages.
                '';
              };

              trusted-public-keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                example = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
                description = "List of public keys used to sign binary caches.";
              };

              extra-trusted-public-keys = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                example = [ "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" ];
                description = "List of public keys used to sign binary caches.";
              };
            };
          };
        };
      };
    };
  };
}
