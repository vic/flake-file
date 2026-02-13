{
  lib,
  options,
  config,
  inputs,
  ...
}:
let
  inherit (import ./../dev/modules/_lib lib) inputsExpr isNonEmptyString nixCode;

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
    let
      nixConfigOptions =
        options.flake-file.valueMeta.configuration.options.nixConfig.valueMeta.configuration.options;
      filteredConfig = lib.filterAttrs (
        name: _: !(nixConfigOptions ? ${name}) || nixConfigOptions.${name}.isDefined
      ) flake-file.nixConfig;
    in
    if filteredConfig != { } then
      ''
        nixConfig = ${nixCode filteredConfig};
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
            diff -u ${inputs.self}/flake.nix ${formatted pkgs}
            ${hooks}
            touch $out
          '';

    };

}
