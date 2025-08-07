{ lib, ... }:
let
  follows-option = lib.mkOption {
    description = "flake input path to follow";
    default = "";
    type = lib.types.str;
  };

  inputs-follow-option = lib.mkOption {
    description = "input dependencies";
    default = { };
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          follows = follows-option;
          inputs = inputs-follow-option;
        };
      }
    );
  };

  inputs-option = lib.mkOption {
    default = { };
    description = "Flake inputs";
    type = lib.types.lazyAttrsOf (
      lib.types.submodule {
        options = {
          url = lib.mkOption {
            description = "source url";
            default = "";
            type = lib.types.str;
          };
          type = lib.mkOption {
            description = "type of flake reference";
            default = null;
            type = lib.types.nullOr (
              lib.types.enum [
                "indirect"
                "path"
                "git"
                "mercurial"
                "tarball"
                "file"
                "github"
                "gitlab"
                "sourcehut"
              ]
            );
          };
          owner = lib.mkOption {
            description = "owner of the repository";
            default = "";
            type = lib.types.str;
          };
          repo = lib.mkOption {
            description = "name of the repository";
            default = "";
            type = lib.types.str;
          };
          path = lib.mkOption {
            description = "path of the flake";
            default = "";
            type = lib.types.str;
          };
          id = lib.mkOption {
            description = "flake registry id";
            default = "";
            type = lib.types.str;
          };
          dir = lib.mkOption {
            description = "subdirectory of the flake";
            default = "";
            type = lib.types.str;
          };
          narHash = lib.mkOption {
            description = "NAR hash of the flake";
            default = "";
            type = lib.types.str;
          };
          rev = lib.mkOption {
            description = "Git/Mercurial commit hash";
            default = "";
            type = lib.types.str;
          };
          ref = lib.mkOption {
            description = "Git/Mercurial branch or tag name";
            default = "";
            type = lib.types.str;
          };
          host = lib.mkOption {
            description = "custom host for github/gitlab/sourcehut";
            default = "";
            type = lib.types.str;
          };
          flake = lib.mkOption {
            description = "is it a flake?";
            type = lib.types.bool;
            default = true;
          };
          follows = follows-option;
          inputs = inputs-follow-option;
        };
      }
    );
  };

in
{
  options.flake-file.inputs = inputs-option;
}
