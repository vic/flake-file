# flake-file - Generate flake.nix from module options.

> A [flake-parts](https://flake.parts/) module that uses [mightyiam/files](https://github.com/mightyiam/files) to automatically generate your `flake.nix` file from module options.

![image](https://github.com/user-attachments/assets/f5af2174-c876-4b3b-97db-95fb2f436883)

## What?

> Ever wanted your `flake.nix` file to be _dynamic_?

Now it is possible for any flake-parts module to
configure input dependencies or nixConfig settings for its containing flake.

## Why?

We configure almost anything and generate countless OS/home config files using nix module options, except (til this day) our very own flake.nix files.

### Features defined by [dendritic](https://github.com/mightyiam/dendritic) flake-parts modules can be self contained.

A flake-parts module can [configure accross different module classes](https://vic.github.io/dendrix/Dendritic.html) `nixos`/`darwin`/`homeManager`/etc _and NOW also_ the `inputs` these configurations depend on.

## Getting Started (try it now!)

To get started quickly, create new flake based on our [dendritic](https://github.com/vic/flake-file/tree/main/templates/dendritic) template:

```shell
nix flake init -t github:vic/flake-file#dendritic
git init                      # for mightyiam/files to find your repo root.
git add .                     # for nix to see repo files.
nix flake check               # checks flake.nix is up to date.
vim modules/default.nix       # add another input.
nix run ".#write-files"       # regen files with mightyiam/files.
cat flake.nix                 # flake.nix built from your options.
```

## Usage

> See also: A real-world example (dogfood flake used to test flake-file) [`dev/`](https://github.com/vic/flake-file/blob/main/dev)

The following is a complete example from our [`templates/dendritic`](https://github.com/vic/flake-file/blob/main/templates/dendritic) template.

It imports all modules from [`flake-file.flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic).
That includes [`flake-parts`](https://flake.parts), [`import-tree`](https://github.com/vic/import-tree) and
will automatically load all your `./modules` files.
It also configures a basic [`treefmt-nix`](https://github.com/numtide/treefmt-nix) formatter.

```nix
{ inputs, ... }:
{
  # That's it! Importing this module will add dendritic-setup inputs to your flake.
  imports = [ inputs.flake-file.flakeModules.dendritic ];
}
```

### Templates

#### `dendritic` template

A template for dendritic setups.

#### `default` template

The default template is a more basic, explicit setup.

```nix
# See templates/default
{ inputs, ... }: {
  imports = [
    inputs.files.flakeModules.default
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = "path:github:vic/flake-file";
    files.url = "github:mightyiam/files";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  systems = import inputs.systems;
  perSystem =
    { config, ... }:
    {
      packages.write-files = config.files.writer.drv;
    };
}
```

And use `nix run .#write-files` to generate. (Tip: you can install it as a shell hook for your devshell)

## Available options.

You already know them! Options are pretty much the flake schema. Except for `follows` (see bellow)

```nix
flake-file.description = "my awesome flake";

flake-file.nixConfig = {}; # an attrset. currently not typed.

flake-file.inputs.<name>.url = "github:foo/bar";
flake-file.inputs.<name>.flake = false;

# This is the only difference from real flake schema.
# maps from `dependency-input` => `flake-input`.
flake-file.inputs.<name>.follows = { "nixpkgs" = "my-nixpkgs"; }
```

See also, [options.nix](https://github.com/vic/flake-file/blob/main/modules/options.nix).

## About the Flake `output` function.

The `flake-file.output` option is a literal nix expression. Because you cannot convert a nix function value into an string for including in the generated flake file.

It defaults to:

```nix
inputs: import ./outputs.nix inputs
```

I (@vic) recommend using this default, because it
makes your flake file _focused_ on definitions
of inputs and nixConfig. All nix logic is
moved to `outputs.nix`. Set this option only if you want to [load another file](https://github.com/vic/flake-file/blob/main/modules/dendritic/import-tree.nix) or simple code, but not for having a huge nix code string in it.

## TODO: Upcoming features

- customize DO-NOT-EDIT header (or disable it)
- option to use another formatter. (currently uses nixfmt-rfc-style)
- validate that target of follows are flake inputs.
- flatten flake inputs.

## Development

```nix
# run tests
nix flake check ./dev --override-input flake-file .

# fmt
nix run ./dev#fmt --override-input flake-file .
```

---

Made with <3 by [@vic](https://x.com/oeiuwq)
