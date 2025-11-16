{
  lib,
  config,
  inputs,
  ...
}:
let
  inherit (import ./../dev/modules/_lib lib) inputsExpr isNonEmptyString;

  flake-file = config.flake-file;

  template = ''
    {
      <description>
      <outputs>
      <nixConfig>
      <inputs>
    }
  '';

  unformatted = lib.pipe template [
    (lib.replaceString "<description>" description)
    (lib.replaceString "<outputs>" outputs)
    (lib.replaceString "<nixConfig>" nixConfig)
    (lib.replaceString "<inputs>" flakeInputs)
    addHeader
  ];

  nixAttr =
    name: value:
    let
      childIsAttr = builtins.isAttrs value;
      childIsOne = builtins.length (builtins.attrNames value) == 1;
      nested = lib.head (lib.mapAttrsToList nixAttr value);
    in
    if childIsAttr && childIsOne then
      {
        name = "${name}.${nested.name}";
        value = nested.value;
      }
    else
      {
        inherit name;
        value = value;
      };

  # expr to code
  nixCode =
    x:
    if lib.isStringLike x then
      lib.strings.escapeNixString x
    else if lib.isAttrs x then
      lib.pipe x [
        (lib.mapAttrsToList nixAttr)
        (map ({ name, value }: ''${name} = ${nixCode value}; ''))
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

  description =
    if isNonEmptyString flake-file.description then
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

  flakeInputs = ''
    inputs = ${nixCode (inputsExpr flake-file.inputs)};
  '';

  addHeader =
    code: if isNonEmptyString flake-file.do-not-edit then flake-file.do-not-edit + code else code;

  formatted =
    pkgs:
    pkgs.stdenvNoCC.mkDerivation {
      name = "flake-formatted";
      passAsFile = [ "unformatted" ];
      inherit unformatted;
      phases = [ "format" ];
      format = ''
        cp $unformattedPath flake.nix
        ${pkgs.lib.getExe (flake-file.formatter pkgs)} flake.nix
        cp flake.nix $out
      '';
    };

in
{
  config.perSystem =
    { pkgs, ... }:
    {
      packages.write-flake =
        let
          hooks = lib.pipe config.flake-file.write-hooks [
            (lib.sortOn (i: i.index))
            (map (i: pkgs.lib.getExe (i.program pkgs)))
            (lib.concatStringsSep "\n")
          ];
        in
        pkgs.writeShellApplication {
          name = "write-flake";
          text = ''
            cp ${formatted pkgs} flake.nix
            ${hooks}
          '';
        };

      checks.check-flake-file =
        let
          hooks = lib.pipe config.flake-file.check-hooks [
            (lib.sortOn (i: i.index))
            (map (i: pkgs.lib.getExe (i.program pkgs)))
            (map (p: "${p} ${inputs.self}"))
            (lib.concatStringsSep "\n")
          ];
        in
        pkgs.runCommand "check-flake-file"
          {
            nativeBuildInputs = [ pkgs.diffutils ];
          }
          ''
            set -e
            diff -u ${formatted pkgs} ${inputs.self}/flake.nix
            ${hooks}
            touch $out
          '';

    };

}
