{ lib, ... }:
let
  esc = lib.escapeShellArg;
  subject = inputs: import ./../_lib/inputs-lib.nix lib esc inputs;

  tests.inputs-lib."pinnableInputs excludes empty-url entries" = {
    expr =
      (subject {
        foo.url = "github:owner/foo";
        bar.url = "";
        baz = { };
      }).pinnableInputs;
    expected = {
      foo.url = "github:owner/foo";
    };
  };

  tests.inputs-lib."pinnableInputs keeps all non-empty urls" = {
    expr =
      lib.attrNames
        (subject {
          a.url = "github:a/a";
          b.url = "github:b/b";
          c.url = "";
        }).pinnableInputs;
    expected = [
      "a"
      "b"
    ];
  };

  tests.inputs-lib."followsInputs excludes inputs with urls" = {
    expr =
      (subject {
        nixpkgs.url = "github:NixOS/nixpkgs";
        nixpkgs-lib.follows = "nixpkgs";
        baz = { };
      }).followsInputs;
    expected = {
      nixpkgs-lib.follows = "nixpkgs";
      baz = { };
    };
  };

  tests.inputs-lib."followsInputs is empty when all inputs have urls" = {
    expr = (subject { nixpkgs.url = "github:NixOS/nixpkgs"; }).followsInputs;
    expected = { };
  };

  tests.inputs-lib."queueSeed contains name and url for each pinnable input" = {
    expr = (subject { foo.url = "github:owner/foo"; }).queueSeed;
    expected = "{\n  printf '%s\\t%s\\n' 'foo' 'github:owner/foo'\n} >> \"$QUEUE_FILE\"";
  };

  tests.inputs-lib."queueSeed is empty block on no pinnable inputs" = {
    expr = (subject { foo.follows = "bar"; }).queueSeed;
    expected = ": >> \"$QUEUE_FILE\"";
  };

  tests.inputs-lib."followsSeed emits printf for each follows-only input" = {
    expr = (subject { nixpkgs-lib.follows = "nixpkgs"; }).followsSeed;
    expected = "{\n  printf '%s\\n' 'nixpkgs-lib'\n} >> \"$FOLLOWS_FILE\"";
  };

  tests.inputs-lib."followsSeed is empty block when all inputs have urls" = {
    expr = (subject { nixpkgs.url = "github:NixOS/nixpkgs"; }).followsSeed;
    expected = ": >> \"$FOLLOWS_FILE\"";
  };

in
{
  flake = { inherit tests; };
}
