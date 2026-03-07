{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs = _inputs: {
    hello = "mundo";
  };

  flake-file.outputs-schema =
    { lib, ... }:
    {
      options.hello = lib.mkOption {
        type = lib.types.enum [
          "mundo"
          "monde"
        ];
      };
    };
}
