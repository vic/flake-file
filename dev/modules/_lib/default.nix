lib:
let

  isNonEmptyString = s: lib.isStringLike s && lib.stringLength (lib.trim s) > 0;

  isEmpty =
    x:
    (
      (builtins.isNull x)
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
      follows = { };
      inputs = nonEmptyInputs input;
    }
  );

  inputsExpr = lib.mapAttrs (
    _name: input:
    mergeNonEmptyAttrs input {
      url = { };
      type = { };
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
      follows = { };
      inputs = nonEmptyInputs input;
    }
  );

in
{
  inherit inputsExpr isNonEmptyString;
}
