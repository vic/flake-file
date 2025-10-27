{ lib, ... }:
let
  inherit (import ./../_lib lib) inputsExpr;

  tests.inputsExpr."test on empty inputs" = {
    expr = inputsExpr { };
    expected = { };
  };

  tests.inputsExpr."test on input without follows" = {
    expr = inputsExpr {
      foo.url = "foo";
    };
    expected = {
      foo.url = "foo";
    };
  };

  tests.inputsExpr."test on input without flake=true" = {
    expr = inputsExpr {
      foo.url = "foo";
      foo.flake = true;
    };
    expected = {
      foo.url = "foo";
    };
  };

  tests.inputsExpr."test on input without flake=false" = {
    expr = inputsExpr {
      foo.url = "foo";
      foo.flake = false;
    };
    expected = {
      foo.url = "foo";
      foo.flake = false;
    };
  };

  tests.inputsExpr."test on input with follows" = {
    expr = inputsExpr {
      foo.url = "foo";
      foo.inputs.bar.follows = "baz";
    };
    expected = {
      foo.url = "foo";
      foo.inputs.bar.follows = "baz";
    };
  };

  tests.inputsExpr."test on input with self follows" = {
    expr = inputsExpr {
      foo.follows = "bar";
    };
    expected = {
      foo.follows = "bar";
    };
  };

  tests.inputsExpr."test on input with follows to empty" = {
    expr = inputsExpr {
      foo.url = "foo";
      foo.inputs.bar.follows = "";
    };
    expected = {
      foo.url = "foo";
      foo.inputs.bar.follows = "";
    };
  };

in
{
  flake = { inherit tests; };
}
