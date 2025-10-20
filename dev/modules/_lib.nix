lib:
let

  isNonEmptyString = s: lib.isStringLike s && lib.stringLength s > 0;

  isEmpty = x: (x == null) || (x == { }) || (x == [ ]) || (!isNonEmptyString x);

  mergeNonEmpty =
    from: name:
    {
      testEmpty ? isEmpty,
      onEmptyMerge ? { },
      nonEmptyMerge ? {
        ${name} = from.${name};
      },
    }:
    acc: acc // (if !from ? ${name} || testEmpty from.${name} then onEmptyMerge else nonEmptyMerge);

  mergeNonEmptyAttrs =
    from: attrs:
    let
      m = mergeNonEmpty from;
      ops = lib.mapAttrsToList (name: spec: (m name spec)) attrs;
    in
    lib.pipe { } ops;

  nonEmptyInputs = input: {
    testEmpty = v: builtins.trace v (v == { });
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
      follow = { };
      flake = {
        testEmpty = v: v;
        nonEmptyMerge = {
          flake = false;
        };
      };
      inputs = nonEmptyInputs input;
    }
  );

in
{
  inherit inputsExpr isNonEmptyString;
}