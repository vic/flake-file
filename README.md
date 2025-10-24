<!-- Badges -->
<p align="right">
  <a href="https://nixos.org/"> <img src="https://img.shields.io/badge/Nix-Flake-informational?logo=nixos&logoColor=white" alt="Nix Flake"/> </a>
  <a href="https://github.com/vic/flake-file/actions">
  <img src="https://github.com/vic/flake-file/workflows/flake-check/badge.svg" alt="CI Status"/> </a>
  <a href="LICENSE"> <img src="https://img.shields.io/github/license/vic/flake-file" alt="License"/> </a>
</p>

# flake-file — Generate flake.nix from flake-parts modules.

**flake-file** lets you generate a clean, maintainable `flake.nix` from modular options, using [flake-parts](https://flake.parts/).

It makes your flake configuration modular and based on the Nix module system. This means you can use
`lib.mkDefault` or anything you normally do with Nix modules, and have them reflected in flake schema values.

<table><tr><td>
  
## Features

- Flake definition aggregated from all flake-parts modules.
- Schema as [options](https://github.com/vic/flake-file/blob/main/modules/options/default.nix).
- Syntax for nixConfig and follows is the same as in flakes.
- `flake check` ensures files are up to date.
- App for generator: `nix run .#write-flake`
- Custom do-not-edit header.
- Automatic flake.lock [flattening](#automatic-flakelock-flattening).
- Incrementally add [flake-parts-builder](#parts_templates) templates.
- Pick flakeModules for different feature sets.
- [Dendritic](https://vic.github.io/dendrix/Dendritic.html) flake template.

</td><td>

<img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/2c0b2208-2f65-4fb3-b9df-5cf78dcad0e7" />

> this cute ouroboros is puking itself out.

</td></tr></table>

---

## Table of Contents

- [Who?](#who-is-this-for)
- [What?](#what-is-flake-file)
- [Getting Started](#getting-started-try-it-now)
- [Usage](#usage)
- [Available Options](#available-options)
- [About the Flake `output` function](#about-the-flake-output-function)
- [Automatic flake.lock flattening](#automatic-flakelock-flattening)
- [Migration Guide](#migration-guide)
- [Development](#development)

---

## Who is this for?

- Nix users who want to keep their `flake.nix` modular and maintainable
- Anyone using [flake-parts](https://flake.parts/) and looking to automate or simplify flake input management
- Teams or individuals who want to share and reuse flake modules across projects

---

## What is flake-file?

flake-file lets you make your `flake.nix` dynamic and modular. Instead of maintaining a single, monolithic `flake.nix`, you define your flake inputs in separate modules _close_ to where their inputs are used. flake-file then automatically generates a clean, up-to-date `flake.nix` for you.

- **Keep your flake modular:** Manage flake inputs just like the rest of your Nix configuration.
- **Automatic updates:** Regenerate your `flake.nix` with a single command whenever your options change.
- **Flake as dependency manifest:** Use `flake.nix` only for declaring dependencies, not for complex Nix code.
- **Share and reuse modules:** Teams can collaborate on and share flake modules across projects, including their dependencies.

> Real-world examples: [vic/vix](https://github.com/vic/vix) uses flake-file. Our [`dev/`](https://github.com/vic/flake-file/blob/main/dev) directory also uses flake-file to test this repo. [More examples on GitHub](https://github.com/search?q=%22vic%2Fflake-file%22+language%3ANix&type=code).

---

## Getting Started (try it now!)

To get started quickly, create a new flake based on our [dendritic](https://github.com/vic/flake-file/tree/main/templates/dendritic) template:

```shell
nix flake init -t github:vic/flake-file#dendritic
nix run ".#write-flake"       # regenerate flake.nix and flake.lock
cat flake.nix                 # flake.nix built from your options
nix flake check               # check that flake.nix is up to date
```

> [!TIP]
> See the [Migration Guide](#migration-guide) if you're moving from an existing flake.

---

## Usage

The following is a complete example from our [`templates/dendritic`](https://github.com/vic/flake-file/blob/main/templates/dendritic) template. It imports all modules from [`flake-file.flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic).

```nix
{ inputs, lib, ... }:
{
  # That's it! Importing this module will add dendritic-setup inputs to your flake.
  imports = [ inputs.flake-file.flakeModules.dendritic ];

  # Define flake attributes on any flake-pars module:
  flake-file = {
    description = "My Awesome Flake";
    inputs.nixpkgs.url = lib.mkDefault "github:NixOS/nixpkgs/nixpkgs-unstable";
    inputs.nixpkgs-lib.follows = "nixpkgs";
  };
}
```

### Available flakeModules

#### [`flakeModules.default`](https://github.com/vic/flake-file/tree/main/modules/default.nix)

- Defines `flake-file` options.
- Exposes `packages.write-flake`.
- Exposes flake checks for generated files.

#### [`flakeModules.import-tree`](https://github.com/vic/flake-file/tree/main/modules/import-tree.nix)

- Adds [import-tree](https://github.com/vic/import-tree)

#### [`lib.flakeModules.flake-parts-builder`](https://github.com/vic/flake-file/tree/main/modules/flake-parts-builder/default.nix)

- Includes flake-parts-builder's `_bootstrap.nix`.
- Uses bootstrap to load parts from ./flake-parts
- Uses bootstrap to load ./flake-parts/\_meta as flake-file configs.

#### [`flakeModules.allfollow`](https://github.com/vic/flake-file/tree/main/modules/prune-lock/allfollow.nix)

- Enables [automatic flake.lock flattening](#automatic-flakelock-flattening) using [spikespaz/allfollow](https://github.com/spikespaz/allfollow)

#### [`flakeModules.nix-auto-follow`](https://github.com/vic/flake-file/tree/main/modules/prune-lock/nix-auto-follow.nix)

- Enables [automatic flake.lock flattening](#automatic-flakelock-flattening) using [fzakaria/nix-auto-follow](https://github.com/fzakaria/nix-auto-follow)

#### [`flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic/default.nix)

- Includes flakeModules.default.
- Includes flakeModules.import-tree.
- Includes flakeModules.nix-auto-follow.
- Enables [`flake-parts`](https://github.com/hercules-ci/flake-parts).
- Enables [`flake-aspects`](https://github.com/vic/flake-aspects).
- Enables [`den`](https://github.com/vic/den).
- Sets `output` function to `import-tree ./modules`.
- Adds `treefmt-nix` input.
- Enables formatters: `nixfmt`, `deadnix`, and `nixf-diagnose`.

### Flake Templates

#### `default` template

A more basic, explicit setup.

```nix
# See templates/default
{ inputs, ... }: {
  imports = [
    inputs.flake-file.flakeModules.default
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  systems = import inputs.systems;
}
```

> [!IMPORTANT]
> Use `nix run .#write-flake` to generate.

> [!TIP]
> You can use the `write-flake` app as part of a devshell or git hook.

#### `dendritic` template

A template for dendritic setups; includes `flakeModules.dendritic`.

#### `parts` template

A template that uses `lib.flakeModules.flake-parts-builder`.

---

## Available Options

Options use the same attributes as the flake schema. See below for details.

| Option                                          | Description                       |
| ----------------------------------------------- | --------------------------------- |
| `flake-file.description`                        | Sets the flake description        |
| `flake-file.nixConfig`                          | Attrset for flake-level nixConfig |
| `flake-file.inputs.<name>.url`                  | URL for a flake input             |
| `flake-file.inputs.<name>.flake`                | Boolean, is input a flake?        |
| `flake-file.inputs.<name>.inputs.<dep>.follows` | Tree of dependencies to follow    |

Example:

```nix
flake-file = {
  description = "my awesome flake";
  nixConfig = {}; # an attrset. currently not typed.
  inputs.<name>.url = "github:foo/bar";
  inputs.<name>.flake = false;
  inputs.<name>.inputs.nixpkgs.follows = "nixpkgs";
};
```

> [!TIP]
> See also, [options.nix](https://github.com/vic/flake-file/blob/main/modules/options/default.nix).

---

## About the Flake `output` function

The `flake-file.output` option is a literal Nix expression. You cannot convert a Nix function value into a string for including in the generated flake file.

It defaults to:

```nix
inputs: import ./outputs.nix inputs
```

We recommend using this default, as it keeps your flake file focused on definitions of inputs and nixConfig. All Nix logic is moved to `outputs.nix`. Set this option only if you want to load another file with [a Nix one-liner](https://github.com/vic/flake-file/blob/main/modules/dendritic/dendritic.nix), but not for including a large Nix code string in it.

---

<a name="parts_templates"></a>

## Add flake-parts-builder templates

Tired of endlessly repeating tiny flake-parts modules or copy-pasting
snippets between your projects? No more!

[flake-parts-builder](https://github.com/tsandrini/flake-parts-builder)
lets you _incrementally_ add templated parts.
This is much better than normal flake templates, since flake-parts templates
can be added or removed at any time, not only at project initialization.

```nix
{ inputs, ... }: {
  imports = [
    (inputs.flake-file.lib.flakeModules.flake-parts-builder ./flake-parts)
  ];
}
```

> [!IMPORTANT]
> Use `github:vic/flake-parts-builder/write-meta` until [flake-parts-builder#60](https://github.com/tsandrini/flake-parts-builder/pull/60) gets merged. This branch will also write each parts meta.nix file, so it can be used by flake-file to manage your flake.nix.

> [!WARNING]
> Only use `flake-parts-builder add` subcommand, since `init` will _overwrite_ the flake.nix file that is already being managed by flake-file.

```shell
nix run github:vic/flake-parts-builder/write-meta -- add --write-meta --parts systems,treefmt $PWD
```

## Hooks for write-flake and checks

You can add custom commands to be run whenever your flake.nix has been
written or checked.

> [!TIP]
> See `flake-file.write-hooks` and `flake-file.check-hooks` options.

## Automatic flake.lock flattening

You can use the `prune-lock` [options](https://github.com/vic/flake-file/blob/main/modules/options.nix)
to specify a command that `flake-file` will use whenever your flake.nix file is generated
to flatten your flake.lock dependency tree.

For flattening mechanisms we provide:

- [`flakeModules.allfollow`](https://github.com/vic/flake-file/blob/main/modules/prune-lock/allfollow.nix) that enables this using [`spikespaz/allfollow`](https://github.com/spikespaz/allfollow)
- [`flakeModules.nix-auto-follow`](https://github.com/vic/flake-file/blob/main/modules/prune-lock/nix-auto-follow.nix) that enables this using [`fzakaria/nix-auto-follow`](https://github.com/fzakaria/nix-auto-follow)

```nix
{ inputs, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.nix-auto-follow
    # or optionally
    #inputs.flake-file.flakeModules.allfollow
  ];
}
```

---

## Migration Guide

This section outlines the recommended steps for adopting `flake-file` in your own repository.

1. **Prerequisite:** Ensure you have already adopted [flake-parts](https://flake.parts).
2. **Add Inputs:** In your current `flake.nix`, add the following input:

   ```nix
   flake-file.url = "github:vic/flake-file";
   ```

3. **Move Outputs:** Copy the contents of your `outputs` function into a file `./outputs.nix`:

   ```nix
   # outputs.nix -- this is the contents of your `outputs` function from the original flake.nix file.
   inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
     imports = [
       ./modules/inputs.nix # Add this for step 4.
       # Feel free to split ./modules/inputs.nix into other modules as you see fit.
       # If you end having lots of modules, consider using import-tree for auto importing them.
     ];
   }
   ```

4. **Move Inputs:** Copy your current flake.nix file as a flake-parts module (e.g., `modules/inputs.nix`):

> [!IMPORTANT]
> Make sure you `git add` so that new files are visible to Nix.

```nix
# modules/inputs.nix
{ inputs, ... }:
{
  imports = [
   inputs.flake-file.flakeModules.default # flake-file options.
  ];
  flake-file = {
    inputs = {
      flake-file.url = "github:vic/flake-file";
      # ... all your other original flake inputs here.
    };
    nixConfig = { }; # if you had any.
    description = "Your flake description";
  };
}
```

5. **Backup:** Back up your flake.nix into flake.nix.bak before regenerating it.
6. **Generate:** Execute `nix run .#write-flake` to generate flake.nix.
7. **Verify:** Check flake.nix and if everything is okay, remove the backup file.

You are done! Now you can split dependencies from `modules/inputs.nix` into other flake-part modules as you see fit:

```nix
# ./modules/<name>.nix -- Replace `<name>` with some dependency.
{ inputs, lib, ... }: {
  flake-file.inputs.<name>.url = ...;

  # Example usage: include the flakeModule once it has been added to flake.nix.
  imports = lib.optionals (inputs ? <name>) [ inputs.<name>.flakeModule ];
}
```

---

## Development

Use `nix develop ./dev` or with direnv: `use flake ./dev`.

```shell
[[general commands]]

  check - run flake check
  fmt   - format all files in repo
  menu  - prints this menu
  regen - regenerate all flake.nix files in this repo
```

---

## Contributing & Support

- Found a bug or have a feature request? [Open an issue](https://github.com/vic/flake-file/issues).
- Contributions are welcome!

---

Made with <3 by [@vic](https://x.com/oeiuwq)
