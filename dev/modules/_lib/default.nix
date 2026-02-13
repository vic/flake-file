lib:
let

  isNonEmptyString = s: lib.isStringLike s && lib.stringLength (lib.trim s) > 0;

  isEmpty =
    x:
    (
      (isNull x)
      || (lib.isStringLike x && lib.stringLength (lib.trim x) == 0)
      || (lib.isList x && lib.length x == 0)
      || (lib.isAttrs x && x == { })
    );

  mergeNonEmpty =
    from: name:
    {
      testEmpty ? isEmpty,
      onEmptyMerge ? { },
      nonEmptyMerge ? {
        ${name} = from.${name};
      },
    }:
    acc: acc // (if (!from ? ${name}) || testEmpty from.${name} then onEmptyMerge else nonEmptyMerge);

  mergeNonEmptyAttrs =
    from: attrs:
    let
      m = mergeNonEmpty from;
      ops = lib.mapAttrsToList (name: spec: (m name spec)) attrs;
    in
    lib.pipe { } ops;

  nonEmptyInputs = input: {
    nonEmptyMerge = {
      inputs = inputsFollow input.inputs;
    };
  };

  inputsFollow = lib.mapAttrs (
    _: input:
    mergeNonEmptyAttrs input {
      follows = {
        testEmpty = v: !builtins.isString v;
      };
      inputs = nonEmptyInputs input;
    }
  );

  inputsExpr = lib.mapAttrs (
    _name: input:
    mergeNonEmptyAttrs input {
      url = { };
      type = { };
      submodules = { };
      owner = { };
      repo = { };
      path = { };
      id = { };
      dir = { };
      narHash = { };
      rev = { };
      ref = { };
      host = { };
      flake = {
        testEmpty = v: v;
        nonEmptyMerge = {
          flake = false;
        };
      };
      follows = {
        testEmpty = x: !builtins.isString x;
      };
      inputs = nonEmptyInputs input;
    }
  );

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
        (map ({ name, value }: "${name} = ${nixCode value}; "))
        (values: "{ ${lib.concatStringsSep " " values} }")
      ]
    else if lib.isList x then
      lib.pipe x [
        (lib.map nixCode)
        (values: "[ ${lib.concatStringsSep " " values} ]")
      ]
    else if x == true then
      "true"
    else if x == false then
      "false"
    else
      toString x;

in
{
  inherit inputsExpr isNonEmptyString nixCode;
}
