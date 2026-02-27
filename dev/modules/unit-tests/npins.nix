{ lib, ... }:
let
  esc = lib.escapeShellArg;

  # Mirrors pinnableInputs from modules/npins.nix
  pinnableInputs = inputs: lib.filterAttrs (_: v: v.url or "" != "") inputs;

  # Mirrors queueSeed from modules/npins.nix
  queueSeed =
    pinnable:
    let
      lines = lib.mapAttrsToList (
        name: input: "  printf '%s\\t%s\\n' ${esc name} ${esc (input.url or "")}"
      ) pinnable;
    in
    "{\n" + lib.concatStringsSep "\n" lines + "\n} >> \"$QUEUE_FILE\"";

  tests.npins."pinnableInputs excludes empty-url entries" = {
    expr = pinnableInputs {
      foo.url = "github:owner/foo";
      bar.url = "";
      baz = { };
    };
    expected = {
      foo.url = "github:owner/foo";
    };
  };

  tests.npins."pinnableInputs keeps all non-empty urls" = {
    expr = lib.attrNames (pinnableInputs {
      a.url = "github:a/a";
      b.url = "github:b/b";
      c.url = "";
    });
    expected = [
      "a"
      "b"
    ];
  };

  tests.npins."pinnableInputs is empty on no-url inputs" = {
    expr = pinnableInputs { foo.follows = "bar"; };
    expected = { };
  };

  tests.npins."queueSeed contains name and url for each pinnable input" = {
    expr = queueSeed { foo.url = "github:owner/foo"; };
    expected = "{\n  printf '%s\\t%s\\n' 'foo' 'github:owner/foo'\n} >> \"$QUEUE_FILE\"";
  };

  tests.npins."queueSeed wraps all printfs in one redirect block" = {
    expr =
      let
        seed = queueSeed {
          a.url = "github:a/a";
          b.url = "github:b/b";
        };
      in
      lib.hasPrefix "{" seed && lib.hasSuffix ">> \"$QUEUE_FILE\"" seed;
    expected = true;
  };

  tests.npins."queueSeed is empty block on no pinnable inputs" = {
    expr = queueSeed { };
    expected = "{\n\n} >> \"$QUEUE_FILE\"";
  };

in
{
  flake = { inherit tests; };
}
