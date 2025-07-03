# flake-file - Generate flake.nix from module options.

> A [flake-parts](https://flake.parts/) module that uses [mightyiam/files](https://github.com/mightyiam/files) to automatically generate your `flake.nix` file from module options.

<table><tr><td>
  
## Features

- Inputs aggregated from all flake-parts modules.
- Simplified follows syntax.
- Supports flake nixConfig.
- `flake check` makes sure files are up to date.
- App for running generator: `nix run .#write-files`
- Custom flake.nix formatter.
- Custom do-not-edit header.
- todo. validate that target of follows are flake inputs.
- todo. flatten flake inputs.
- Provides basic and Dendritic flakeModules.
- Provides basic and Dendritic templates for quickstart.

</td><td>

![image](https://github.com/user-attachments/assets/f5af2174-c876-4b3b-97db-95fb2f436883)

</td></tr></table>

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

> A real-world example is @vic's [vic/vix](https://github.com/vic/vix/blob/main/modules/flake/dendritic.nix).
> And our [`dev/`](https://github.com/vic/flake-file/blob/main/dev) dogfood flake used to test this repo.

The following is a complete example from our [`templates/dendritic`](https://github.com/vic/flake-file/blob/main/templates/dendritic) template.

It imports all modules from [`flake-file.flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic).

```nix
{ inputs, ... }:
{
  # That's it! Importing this module will add dendritic-setup inputs to your flake.
  imports = [ inputs.flake-file.flakeModules.dendritic ];
}
```

### Available flakeModules

#### `flakeModules.default`

- Defines `flake-file` options.
- Exposes `packages.write-files`.
- Exposes flake checks for generated files.

#### `flakeModules.dendritic`

- Includes flakeModules.default.
- Adds `flake-parts` input.
- Enables `flake.modules` option used in dendritic setups.
- Adds `import-tree` input.
- Sets `output` function to `import-tree ./modules`.
- Setups `treefmt-nix` formatter with support for `nixfmt`, `deadnix` and `nixf-diagnose`.

### Templates

#### `dendritic` template

A template for dendritic setups, includes `flakeModules.dendritic`.

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
moved to `outputs.nix`. Set this option only if you want to load another file with [a nix one-liner](https://github.com/vic/flake-file/blob/main/modules/dendritic/dendritic.nix), but not for having a huge nix code string in it.

## Development

```nix
# run tests
nix flake check ./dev --override-input flake-file .

# fmt
nix run ./dev#fmt

# regenerate all flake.nix files on this repo.
nix run ./dev#regen
```

---

Made with <3 by [@vic](https://x.com/oeiuwq)
