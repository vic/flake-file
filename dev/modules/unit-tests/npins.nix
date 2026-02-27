{ lib, ... }:
let
  esc = lib.escapeShellArg;
  subject = inputs: import ./../_lib/inputs-lib.nix lib esc inputs;

  tests.npins."queueSeed wraps all entries in one redirect block" = {
    expr =
      let
        seed =
          (subject {
            a.url = "github:a/a";
            b.url = "github:b/b";
          }).queueSeed;
      in
      lib.hasPrefix "{" seed && lib.hasSuffix ">> \"$QUEUE_FILE\"" seed;
    expected = true;
  };

  tests.npins."pinnableInputs is empty on no-url inputs" = {
    expr = (subject { foo.follows = "bar"; }).pinnableInputs;
    expected = { };
  };

in
{
  flake = { inherit tests; };
}
