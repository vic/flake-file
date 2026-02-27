{ lib, ... }:
let
  parse = import ./../_lib/parse-url.nix lib;
  p = url: parse url;

  # ── github ──────────────────────────────────────────────────────────────────
  tests.parse-url."github: basic" = {
    expr = p "github:NixOS/nixpkgs";
    expected = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "";
      rev = "";
      host = "github.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."github: branch ref" = {
    expr = p "github:NixOS/nixpkgs/nixos-23.11";
    expected = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-23.11";
      rev = "";
      host = "github.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."github: commit hash" = {
    expr = p "github:NixOS/nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";
    expected = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";
      rev = "";
      host = "github.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."github: pull request ref" = {
    expr = p "github:NixOS/nixpkgs/pull/357207/head";
    expected = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "pull/357207/head";
      rev = "";
      host = "github.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."github: custom host" = {
    expr = p "github:internal/project?host=company-github.example.org";
    expected = {
      type = "github";
      owner = "internal";
      repo = "project";
      ref = "";
      rev = "";
      host = "company-github.example.org";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."github: dir parameter" = {
    expr = p "github:edolstra/nix-warez?dir=blender";
    expected = {
      type = "github";
      owner = "edolstra";
      repo = "nix-warez";
      ref = "";
      rev = "";
      host = "github.com";
      dir = "blender";
      url = "";
    };
  };

  tests.parse-url."github: rev query param" = {
    expr = p "github:NixOS/nixpkgs?rev=a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";
    expected = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "";
      rev = "a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";
      host = "github.com";
      dir = "";
      url = "";
    };
  };

  # ── gitlab ──────────────────────────────────────────────────────────────────
  tests.parse-url."gitlab: basic" = {
    expr = p "gitlab:veloren/veloren";
    expected = {
      type = "gitlab";
      owner = "veloren";
      repo = "veloren";
      ref = "";
      rev = "";
      host = "gitlab.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."gitlab: branch ref" = {
    expr = p "gitlab:veloren/veloren/master";
    expected = {
      type = "gitlab";
      owner = "veloren";
      repo = "veloren";
      ref = "master";
      rev = "";
      host = "gitlab.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."gitlab: commit hash" = {
    expr = p "gitlab:veloren/veloren/80a4d7f13492d916e47d6195be23acae8001985a";
    expected = {
      type = "gitlab";
      owner = "veloren";
      repo = "veloren";
      ref = "80a4d7f13492d916e47d6195be23acae8001985a";
      rev = "";
      host = "gitlab.com";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."gitlab: custom host" = {
    expr = p "gitlab:openldap/openldap?host=git.openldap.org";
    expected = {
      type = "gitlab";
      owner = "openldap";
      repo = "openldap";
      ref = "";
      rev = "";
      host = "git.openldap.org";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."gitlab: percent-encoded subgroup" = {
    expr = p "gitlab:veloren%2Fdev/rfcs";
    expected = {
      type = "gitlab";
      owner = "veloren/dev";
      repo = "rfcs";
      ref = "";
      rev = "";
      host = "gitlab.com";
      dir = "";
      url = "";
    };
  };

  # ── sourcehut ───────────────────────────────────────────────────────────────
  tests.parse-url."sourcehut: basic with tilde" = {
    expr = p "sourcehut:~misterio/nix-colors";
    expected = {
      type = "sourcehut";
      owner = "misterio";
      repo = "nix-colors";
      ref = "";
      rev = "";
      host = "git.sr.ht";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."sourcehut: branch ref" = {
    expr = p "sourcehut:~misterio/nix-colors/main";
    expected = {
      type = "sourcehut";
      owner = "misterio";
      repo = "nix-colors";
      ref = "main";
      rev = "";
      host = "git.sr.ht";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."sourcehut: custom host" = {
    expr = p "sourcehut:~misterio/nix-colors?host=git.example.org";
    expected = {
      type = "sourcehut";
      owner = "misterio";
      repo = "nix-colors";
      ref = "";
      rev = "";
      host = "git.example.org";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."sourcehut: commit hash" = {
    expr = p "sourcehut:~misterio/nix-colors/182b4b8709b8ffe4e9774a4c5d6877bf6bb9a21c";
    expected = {
      type = "sourcehut";
      owner = "misterio";
      repo = "nix-colors";
      ref = "182b4b8709b8ffe4e9774a4c5d6877bf6bb9a21c";
      rev = "";
      host = "git.sr.ht";
      dir = "";
      url = "";
    };
  };

  tests.parse-url."sourcehut: mercurial host" = {
    expr = p "sourcehut:~misterio/nix-colors/21c1a380?host=hg.sr.ht";
    expected = {
      type = "sourcehut";
      owner = "misterio";
      repo = "nix-colors";
      ref = "21c1a380";
      rev = "";
      host = "hg.sr.ht";
      dir = "";
      url = "";
    };
  };

  # ── git ─────────────────────────────────────────────────────────────────────
  tests.parse-url."git+https: basic" = {
    expr = (p "git+https://example.org/my/repo").type;
    expected = "git";
  };

  tests.parse-url."git+https: with ref" = {
    expr = p "git+https://example.org/my/repo?ref=master";
    expected = {
      type = "git";
      owner = "";
      repo = "";
      ref = "master";
      rev = "";
      host = "";
      dir = "";
      url = "git+https://example.org/my/repo";
    };
  };

  tests.parse-url."git+https: with ref and rev" = {
    expr = p "git+https://example.org/my/repo?ref=master&rev=f34751b88bd07d7f44f5cd3200fb4122bf916c7e";
    expected = {
      type = "git";
      owner = "";
      repo = "";
      ref = "master";
      rev = "f34751b88bd07d7f44f5cd3200fb4122bf916c7e";
      host = "";
      dir = "";
      url = "git+https://example.org/my/repo";
    };
  };

  tests.parse-url."git: bare scheme with ref and rev" = {
    expr = p "git://github.com/edolstra/dwarffs?ref=unstable&rev=e486d8d40e626a20e06d792db8cc5ac5aba9a5b4";
    expected = {
      type = "git";
      owner = "";
      repo = "";
      ref = "unstable";
      rev = "e486d8d40e626a20e06d792db8cc5ac5aba9a5b4";
      host = "";
      dir = "";
      url = "git://github.com/edolstra/dwarffs";
    };
  };

  tests.parse-url."git+ssh: with ref" = {
    expr = p "git+ssh://git@github.com/NixOS/nix?ref=v1.2.3";
    expected = {
      type = "git";
      owner = "";
      repo = "";
      ref = "v1.2.3";
      rev = "";
      host = "";
      dir = "";
      url = "git+ssh://git@github.com/NixOS/nix";
    };
  };

  tests.parse-url."git+file: local" = {
    expr = (p "git+file:///home/my-user/some-repo").type;
    expected = "git";
  };

  # ── tarball ─────────────────────────────────────────────────────────────────
  tests.parse-url."tarball: https scheme" = {
    expr = p "https://github.com/NixOS/patchelf/archive/master.tar.gz";
    expected = {
      type = "tarball";
      owner = "";
      repo = "";
      ref = "";
      rev = "";
      host = "";
      dir = "";
      url = "https://github.com/NixOS/patchelf/archive/master.tar.gz";
    };
  };

  tests.parse-url."tarball+https: explicit scheme" = {
    expr = (p "tarball+https://example.org/repo.tar.gz").type;
    expected = "tarball";
  };

  tests.parse-url."tarball+https: strips prefix from url" = {
    expr = (p "tarball+https://example.org/repo.tar.gz").url;
    expected = "https://example.org/repo.tar.gz";
  };

  tests.parse-url."tarball: nixos channel url" = {
    expr = (p "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz").type;
    expected = "tarball";
  };

  tests.parse-url."tarball: zip extension" = {
    expr = (p "https://example.org/archive.zip").type;
    expected = "tarball";
  };

  # ── file ────────────────────────────────────────────────────────────────────
  tests.parse-url."file+http: type" = {
    expr = (p "file+http://example.org/foo").type;
    expected = "file";
  };

  tests.parse-url."file+https: strips prefix" = {
    expr = (p "file+https://example.org/foo").url;
    expected = "https://example.org/foo";
  };

  # ── mercurial ───────────────────────────────────────────────────────────────
  tests.parse-url."hg+https: type" = {
    expr = (p "hg+https://example.org/my/repo").type;
    expected = "mercurial";
  };

  tests.parse-url."hg+https: with ref" = {
    expr = (p "hg+https://example.org/my/repo?ref=default").ref;
    expected = "default";
  };

  # ── path ────────────────────────────────────────────────────────────────────
  tests.parse-url."path: absolute" = {
    expr = (p "path:/home/user/sub/dir").type;
    expected = "path";
  };

in
{
  flake = { inherit tests; };
}
