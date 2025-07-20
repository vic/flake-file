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

      unformatted =
        let
          template = ''
            {
              <description>
              <outputs>
              <nixConfig>
              <inputs>
            }
          '';

          description =
            if nonEmpty flake-file.description then
              ''
                description = ${nixCode flake-file.description};
              ''
            else
              "";

          outputs = ''
            outputs = ${flake-file.outputs};
          '';

          nixConfig =
            if flake-file.nixConfig != { } then
              ''
                nixConfig = ${nixCode flake-file.nixConfig};
              ''
            else
              "";

          inputsFollow = lib.mapAttrs (
            _: input:
            { }
            // (if !input ? follows || input.follows == { } then { } else { inherit (input) follows; })
            // (if !input ? inputs || input.inputs == { } then { } else { inputs = inputsFollow input.inputs; })
          );

          inputsExpr = lib.mapAttrs (
            _name: input:
            { }
            // (if !input ? url || input.url == "" then { } else { inherit (input) url; })
            // (if !input ? follows || input.follows == "" then { } else { inherit (input) follows; })
            // (if !input ? flake || input.flake then { } else { flake = false; })
            // (
              if !input ? inputs || input.inputs == { } then
                { }
              else
                {
                  inputs = inputsFollow input.inputs;
                }
            )
          ) flake-file.inputs;

          inputs = ''
            inputs = ${nixCode inputsExpr};
          '';

          addHeader = code: if nonEmpty flake-file.do-not-edit then flake-file.do-not-edit + code else code;
        in
        lib.pipe template [
          (lib.replaceString "<description>" description)
          (lib.replaceString "<outputs>" outputs)
          (lib.replaceString "<nixConfig>" nixConfig)
          (lib.replaceString "<inputs>" inputs)
          addHeader
        ];

      formatted = pkgs.stdenvNoCC.mkDerivation {
        name = "flake-formatted";
        passAsFile = [ "unformatted" ];
        inherit unformatted;
        phases = [ "format" ];
        format = ''
          cp $unformattedPath flake.nix
          ${flake-file.formatter pkgs} flake.nix
          cp flake.nix $out
        '';
      };

      prune-lock-run =
        let
          cmd = pkgs.lib.getExe (flake-file.prune-lock.program pkgs);
          app = pkgs.writeShellApplication {
            name = "prune-lock";
            text = ''
              set -e
              if [ "apply" == "$1" ]; then
                nix flake lock
                ${cmd} flake.lock pruned.lock
                mv pruned.lock flake.lock
              fi
              if [ "check" == "$1" ]; then
                ${cmd} "$2" pruned.lock
                delta --paging never pruned.lock "$2"
              fi
            '';
          };
        in
        if flake-file.prune-lock.enable then pkgs.lib.getExe app else "true";

      write-flake = pkgs.writeShellApplication {
        name = "write-flake";
        text = ''
          set -e
          cp ${formatted} flake.nix
          ${prune-lock-run} apply
        '';
      };

      prune-lock = pkgs.writeShellApplication {
        name = "prune-lock";
        text = ''
          ${prune-lock-run} apply
        '';
      };

      check-flake-file =
        pkgs.runCommand "check-flake-file"
          {
            nativeBuildInputs = [ pkgs.delta ];
          }
          ''
            set -e
            delta --paging never ${formatted} ${inputs.self}/flake.nix
            ${prune-lock-run} check ${inputs.self}/flake.lock
            touch $out
          '';
    in
    {
      packages = { inherit write-flake prune-lock; };
      checks = { inherit check-flake-file; };
    };

}
