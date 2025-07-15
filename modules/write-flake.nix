{
  lib,
  config,
  inputs,
  ...
}:
{
  config.perSystem =
    { pkgs, inputs', ... }:
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
            {
              inherit (input) url;
            }
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

      allfollow-run = (import ./allfollow.nix lib).runner { inherit pkgs inputs'; };

      write-flake = pkgs.writeShellApplication {
        name = "write-flake";
        text = ''
          set -e
          cp ${formatted} flake.nix
          # ${lib.getExe allfollow-run} apply
        '';
      };

      check-flake =
        pkgs.runCommand "check-flake-file"
          {
            nativeBuildInputs = [ pkgs.delta ];
          }
          ''
            set -e
            delta --paging never --side-by-side ${formatted} ${inputs.self}/flake.nix
            # ${lib.getExe allfollow-run} check ${inputs.self}/flake.lock
            touch $out
          '';
    in
    {
      packages = { inherit write-flake; };
      checks = { inherit check-flake; };
    };

}
