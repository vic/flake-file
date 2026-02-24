<!-- Badges -->

<p align="right">
  <a href="https://github.com/sponsors/vic"><img src="https://img.shields.io/badge/sponsor-vic-white?logo=githubsponsors&logoColor=white&labelColor=%23FF0000" alt="Sponsor Vic"/>
  </a>
  <a href="https://vic.github.io/dendrix/Dendritic-Ecosystem.html#vics-dendritic-libraries"> <img src="https://img.shields.io/badge/Dendritic-Nix-informational?logo=nixos&logoColor=white" alt="Dendritic Nix"/> </a>
  <a href="https://github.com/vic/flake-file/actions">
  <img src="https://github.com/vic/flake-file/workflows/flake-check/badge.svg" alt="CI Status"/> </a>
  <a href="LICENSE"> <img src="https://img.shields.io/github/license/vic/flake-file" alt="License"/> </a>
</p>

# Generate `flake.nix`/`unflake.nix`/`npins` from inputs defined as module options.

> `flake-file` and [vic](https://bsky.app/profile/oeiuwq.bsky.social)'s [dendritic libs](https://vic.github.io/dendrix/Dendritic-Ecosystem.html#vics-dendritic-libraries) made for you with Love++ and AI--. If you like my work, consider [sponsoring](https://github.com/sponsors/vic)

**flake-file** lets you generate a clean, maintainable `flake.nix` from modular options. Use the _real_ Nix language to define your inputs.

It makes your flake configuration modular and based on the Nix module system. This means you can use
`lib.mkDefault` or anything you normally do with Nix modules, and have them reflected in flake schema values.

> Despite the original flake-oriented name, it NOW also works on _stable Nix_, non-flakes environments via [npins](templates/npins) or [unflake](templates/unflake).

<table><tr><td>

## Features

- Flake definition aggregated from Nix modules.
- Schema as [options](https://github.com/vic/flake-file/blob/main/modules/options/default.nix).
- Syntax for nixConfig and follows is the same as in flakes.
- `flake check` ensures files are up to date.
- App for `flake.nix` generator: `nix run .#write-flake`
- Custom do-not-edit header.
- Automatic flake.lock [flattening](#automatic-flakelock-flattening).
- Incrementally add [flake-parts-builder](#parts_templates) templates.
- Pick flakeModules for different feature sets.
- [Dendritic](https://vic.github.io/dendrix/Dendritic.html) flake template.
- Works on stable Nix, [npins](templates/npins) and [unflake](templates/unflake) environments.

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
- Anyone using Nix modules and looking to automate or simplify flake input management
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

  # Define flake attributes on any flake-parts module:
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
- Enables [`flake-parts`](https://github.com/hercules-ci/flake-parts).
- Sets `outputs` to `inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)`.

> Previously, this module included `flake-aspects` and `den` as dependencies. It now provides a pure flake-parts Dendritic setup. If you need the complete [den](https://github.com/vic/den) functionality, use den's `flakeModules.dendritic` instead.

#### [`flakeModules.npins`](https://github.com/vic/flake-file/tree/main/modules/npins.nix)

- Defines `flake-file` options for [npins](https://github.com/andir/npins)-based dependency pinning.
- Exposes `write-npins` to generate/update the `npins/` directory from declared inputs.
- Supports `github`, `gitlab`, `channel`, `tarball`, and `git` URL schemes.
- Respects `follows` for transitive dependency deduplication.
- Prunes stale pins automatically.
- See [templates/npins](templates/npins) for usage.

#### [`flakeModules.unflake`](https://github.com/vic/flake-file/tree/main/modules/unflake.nix)

- Defines `flake-file` options.
- Exposes `write-unflake` to generate `unflake.nix` or `npins`. See [templates/unflake](templates/unflake) for usage.

### Flake Templates

#### [`default`](templates/default) template

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
  };

  systems = inputs.nixpkgs.lib.systems.flakeExposed;
}
```

> [!IMPORTANT]
> Use `nix run .#write-flake` to generate.

> [!TIP]
> You can use the `write-flake` app as part of a devshell or git hook.

#### [`dendritic`](templates/dendritic) template

A template for dendritic setups; includes `flakeModules.dendritic`.

#### [`parts`](templates/parts) template

A template that uses `lib.flakeModules.flake-parts-builder`.

#### [`npins`](templates/npins) template

Uses [npins](https://github.com/andir/npins) to pin and fetch inputs defined as options for non-flakes stable Nix environments. Supports channels, GitHub, GitLab, tarballs, and git repos. Recommended for new non-flake projects.

#### [`unflake`](templates/unflake) template

Uses [goldstein/unflake](https://codeberg.org/goldstein/unflake) to pin and fetch inputs that were defined as options for non-flakes stable Nix environments.

---

## Available Options

Options use the same attributes as the flake schema. See below for details.

| Option                                            | Description                                                 |
| ------------------------------------------------- | ----------------------------------------------------------- |
| `flake-file.description`                          | Sets the flake description                                  |
| `flake-file.nixConfig`                            | Flake-level `nixConfig` (typed attrset)                     |
| `flake-file.outputs`                              | Literal Nix code for `outputs` function                     |
| `flake-file.formatter`                            | Function: `pkgs -> program` to format generated `flake.nix` |
| `flake-file.do-not-edit`                          | Header comment added atop generated file                    |
| `flake-file.inputs.<name>.url`                    | Source URL (e.g. `github:owner/repo`)                       |
| `flake-file.inputs.<name>.type`                   | Reference type (`github`, `path`, etc.)                     |
| `flake-file.inputs.<name>.owner`                  | Owner (for typed VCS refs)                                  |
| `flake-file.inputs.<name>.repo`                   | Repo name                                                   |
| `flake-file.inputs.<name>.path`                   | Local path reference                                        |
| `flake-file.inputs.<name>.id`                     | Flake registry id                                           |
| `flake-file.inputs.<name>.dir`                    | Subdirectory within repo/path                               |
| `flake-file.inputs.<name>.narHash`                | NAR hash pin                                                |
| `flake-file.inputs.<name>.rev`                    | Commit hash pin                                             |
| `flake-file.inputs.<name>.ref`                    | Branch or tag pin                                           |
| `flake-file.inputs.<name>.host`                   | Custom host for git forges                                  |
| `flake-file.inputs.<name>.submodules`             | Whether to fetch git submodules                             |
| `flake-file.inputs.<name>.flake`                  | Boolean: is it a flake? (default true)                      |
| `flake-file.inputs.<name>.follows`                | Follow another input's value                                |
| `flake-file.inputs.<name>.inputs.<dep>.follows`   | Nested input follow tree                                    |
| `flake-file.inputs.<name>.inputs.<dep>.inputs...` | Recursively follow deeper deps                              |
| `flake-file.write-hooks`                          | List of ordered hooks (by `index`) after writing            |
| `flake-file.check-hooks`                          | List of ordered hooks (by `index`) during check             |
| `flake-file.prune-lock.enable`                    | Enable automatic flake.lock pruning                         |
| `flake-file.prune-lock.program`                   | Function building pruning executable                        |

Example:

```nix
flake-file = {
  description = "my awesome flake";
  nixConfig = {}; # attrset (free-form, typed as attrs)
  inputs.<name>.url = "github:foo/bar";
  inputs.<name>.flake = false;
  inputs.<name>.inputs.nixpkgs.follows = "nixpkgs";
};
```

> [!TIP]
> See also, [options.nix](https://github.com/vic/flake-file/blob/main/modules/options/default.nix).

---

## About the Flake `outputs` function

The `flake-file.outputs` option is a literal Nix expression. You cannot convert a Nix function value into a string for including in the generated flake file.

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

You can use the `prune-lock` [options](https://github.com/vic/flake-file/blob/main/modules/options/prune-lock.nix)
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
    # inputs.flake-file.flakeModules.allfollow
  ];
}
```

---

## Migration Guide

This section outlines the recommended steps for adopting `flake-file` in your own repository.

1. **Prerequisite:** Ensure you have already adopted [flake-parts](https://flake.parts).

1. **Add Inputs:** In your current `flake.nix`, add the following input:

   ```nix
   flake-file.url = "github:vic/flake-file";
   ```

1. **Move Outputs:** Copy the contents of your `outputs` function into a file `./outputs.nix`:

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

1. **Move Inputs:** Copy your current flake.nix file as a flake-parts module (e.g., `modules/inputs.nix`):

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
1. **Generate:** Execute `nix run .#write-flake` to generate flake.nix.
1. **Verify:** Check flake.nix and if everything is okay, remove the backup file.

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

Made with \<3 by [@vic](https://x.com/oeiuwq)
