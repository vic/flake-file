{ inputs, ... }:
let
  normalize = import "${inputs.flake-file}/modules/deps/normalize.nix";

  mkFlake = content: builtins.toFile "flake.nix" content;

  norm = content: normalize (mkFlake content);

  tests.normalize."url form: github" = {
    expr = norm ''{ inputs.nixpkgs.url = "github:NixOS/nixpkgs"; outputs = _: {}; }'';
    expected = {
      nixpkgs = "github:NixOS/nixpkgs";
    };
  };

  tests.normalize."attrset form: github basic" = {
    expr = norm ''{ inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; }; outputs = _: {}; }'';
    expected = {
      nixpkgs = "github:NixOS/nixpkgs";
    };
  };

  tests.normalize."attrset form: github with ref" = {
    expr = norm ''{ inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; ref = "nixos-23.11"; }; outputs = _: {}; }'';
    expected = {
      nixpkgs = "github:NixOS/nixpkgs/nixos-23.11";
    };
  };

  tests.normalize."attrset form: github with rev" = {
    expr = norm ''{ inputs.nixpkgs = { type = "github"; owner = "NixOS"; repo = "nixpkgs"; rev = "abc123"; }; outputs = _: {}; }'';
    expected = {
      nixpkgs = "github:NixOS/nixpkgs/abc123";
    };
  };

  tests.normalize."attrset form: github with host" = {
    expr = norm ''{ inputs.foo = { type = "github"; owner = "org"; repo = "bar"; host = "ghe.example.com"; }; outputs = _: {}; }'';
    expected = {
      foo = "github:org/bar?host=ghe.example.com";
    };
  };

  tests.normalize."attrset form: gitlab" = {
    expr = norm ''{ inputs.foo = { type = "gitlab"; owner = "veloren"; repo = "veloren"; }; outputs = _: {}; }'';
    expected = {
      foo = "gitlab:veloren/veloren";
    };
  };

  tests.normalize."attrset form: sourcehut" = {
    expr = norm ''{ inputs.foo = { type = "sourcehut"; owner = "misterio"; repo = "nix-colors"; }; outputs = _: {}; }'';
    expected = {
      foo = "sourcehut:~misterio/nix-colors";
    };
  };

  tests.normalize."attrset form: git" = {
    expr = norm ''{ inputs.foo = { type = "git"; url = "git+https://example.org/my/repo"; ref = "main"; }; outputs = _: {}; }'';
    expected = {
      foo = "git+https://example.org/my/repo?ref=main";
    };
  };

  tests.normalize."follows: omitted from output" = {
    expr = norm ''{ inputs.nixpkgs-lib.follows = "nixpkgs"; inputs.nixpkgs.url = "github:NixOS/nixpkgs"; outputs = _: {}; }'';
    expected = {
      nixpkgs = "github:NixOS/nixpkgs";
      nixpkgs-lib = "";
    };
  };

  tests.normalize."no inputs: empty attrset" = {
    expr = norm "{ outputs = _: {}; }";
    expected = { };
  };

in
{
  flake = { inherit tests; };
}
