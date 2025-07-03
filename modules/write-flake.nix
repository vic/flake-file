{
  lib,
  config,
  inputs,
  ...
}:
{
  config.perSystem =
    { pkgs, ... }:
    let
      flake-file = config.flake-file;
      nonEmpty = s: lib.isStringLike s && lib.stringLength s > 0;

      flake =
        {
          outputs = "outputs";
        }
        // (if nonEmpty flake-file.description then { inherit (flake-file) description; } else { })
        // (if flake-file.nixConfig != { } then { inherit (flake-file) nixConfig; } else { })
        // {
          inputs = lib.mapAttrs (
            _name: input:
            {
              inherit (input) url;
            }
            // (if input.flake then { } else { flake = false; })
            // (
              if input.follows == { } then
                { }
              else
                {
                  inputs = lib.mapAttrs (_: follows: {
                    inherit follows;
                  }) input.follows;
                }
            )
          ) flake-file.inputs;
        };

      # expr to code
      nixCode =
        x:
        if lib.isStringLike x then
          lib.strings.escapeNixString x
        else if lib.isAttrs x then
          lib.pipe x [
            (lib.mapAttrsToList (name: value: ''${name} = ${nixCode value}; ''))
            (values: ''{ ${lib.concatStringsSep " " values} }'')
          ]
        else if lib.isList x then
          lib.pipe x [
            (lib.map nixCode)
            (values: ''[ ${lib.concatStringsSep " " values} ]'')
          ]
        else if x == true then
          "true"
        else if x == false then
          "false"
        else
          toString x;

      unformatted = lib.pipe flake [
        nixCode
        (lib.replaceString ''outputs = "outputs";'' ''outputs = ${flake-file.outputs};'')
        (code: if nonEmpty flake-file.do-not-edit then flake-file.do-not-edit + code else code)
      ];

      formatted = pkgs.stdenvNoCC.mkDerivation {
        name = "flake-formatted";
        nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
        passAsFile = [ "unformatted" ];
        inherit unformatted;
        phases = [ "format" ];
        format = ''
          cp $unformattedPath flake.nix
          ${flake-file.formatter pkgs} flake.nix
          cp flake.nix $out
        '';
      };

      auto-follow =
        let
          src = pkgs.fetchFromGitHub {
            owner = "fzakaria";
            repo = "nix-auto-follow";
            rev = "0200e8c";
            hash = "sha256-uXK9+U22FI5WQJfLWFQXvq8v4VT14ms4N6Fj2I5boiU=";
          };
          pkg =
            if flake-file.auto-follow.pkg == null then
              pkgs.callPackage "${src}/derivation.nix" { }
            else
              flake-file.auto-follow.pkg;
        in
        pkg;

      nothing = pkgs.writeShellApplication {
        name = "nothing";
        text = "true";
      };

      auto-follow-run =
        if !flake-file.auto-follow.enable then
          nothing
        else
          pkgs.writeShellApplication {
            name = "auto-follow-run";
            text = ''
              if test "-i" == "''${1:-}"; then
                nix flake lock
              fi
              if test -f flake.lock; then
                ${lib.getExe auto-follow} "$@"
              fi
            '';
          };

      write-flake = pkgs.writeShellApplication {
        name = "write-flake";
        text = ''
          cp ${formatted} flake.nix
          ${lib.getExe auto-follow-run} -i
        '';
      };

      check-flake =
        pkgs.runCommand "check-flake-file"
          {
            nativeBuildInputs = [ pkgs.difftastic ];
          }
          ''
            cd ${inputs.self}
            difft --exit-code --display inline ${formatted} flake.nix
            ${lib.getExe auto-follow-run} -c
            touch $out
          '';
    in
    {
      packages = { inherit write-flake; };
      checks = { inherit check-flake; };
    };

}
