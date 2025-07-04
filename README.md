<!-- Badges -->
<p align="right">
  <a href="https://nixos.org/"> <img src="https://img.shields.io/badge/Nix-Flake-informational?logo=nixos&logoColor=white" alt="Nix Flake"/> </a>
  <a href="https://github.com/vic/flake-file/actions"> <img src="https://github.com/vic/flake-file/workflows/flake-check/badge.svg" alt="CI Status"/> </a>
  <a href="LICENSE"> <img src="https://img.shields.io/github/license/vic/flake-file" alt="License"/> </a>
</p>

# flake-file — Generate flake.nix from flake-parts modules.

**flake-file** lets you generate a clean, maintainable `flake.nix` from modular options, using [flake-parts](https://flake.parts/).

It makes your flake configuration modular and based on the Nix module system. This means you can use
`lib.mkDefault` or anything you normally do on Nix modules, and have them reflected on flake schema values.

<table><tr><td>
  
## Features

- Flake definition aggregated from all flake-parts modules.
- Schema as [options](https://github.com/vic/flake-file/blob/main/modules/options.nix).
- Simplified follows syntax.
- Supports flake nixConfig.
- `flake check` ensures files are up to date.
- App for generator: `nix run .#write-flake`
- Custom flake.nix formatter.
- Custom do-not-edit header.
- Automatic flake.lock [flattening](#automatic-flakelock-flattening).
- Basic and Dendritic flakeModules.
- Basic and Dendritic flake templates.

</td><td style="width: 20em">

![image](https://github.com/user-attachments/assets/f5af2174-c876-4b3b-97db-95fb2f436883)

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

flake-file lets you make your `flake.nix` dynamic and modular. Instead of maintaining a single, monolithic `flake.nix`, you define your flake inputs in separate modules _near_ to their input use. flake-file then automatically generates a clean, up-to-date `flake.nix` for you.

- **Keep your flake modular:** Manage flake inputs just like the rest of your Nix configuration.
- **Automatic updates:** Regenerate your `flake.nix` with a single command whenever your options change.
- **Flake as dependency manifest:** Use `flake.nix` only for declaring dependencies, not for complex Nix code.
- **Share and reuse modules:** Teams can collaborate and share flake modules across projects including their dependencies.

> Real-world examples: [vic/vix](https://github.com/vic/vix) uses flake-file. Our [`dev/`](https://github.com/vic/flake-file/blob/main/dev) directory also uses flake-file to test this repo. [More examples on GitHub](https://github.com/search?q=%22flake-file.inputs+%3D%22+language%3ANix&type=code).

---

## Getting Started (try it now!)

To get started quickly, create a new flake based on our [dendritic](https://github.com/vic/flake-file/tree/main/templates/dendritic) template:

```shell
nix flake init -t github:vic/flake-file#dendritic
nix flake check               # checks flake.nix is up to date.
vim modules/default.nix       # add another input.
nix run ".#write-flake"       # regenerate flake
cat flake.nix                 # flake.nix built from your options.
nix flake check               # checks flake.nix is up to date.
```

> See the [Migration Guide](#migration-guide) if moving from an existing flake.

---

## Usage

The following is a complete example from our [`templates/dendritic`](https://github.com/vic/flake-file/blob/main/templates/dendritic) template. It imports all modules from [`flake-file.flakeModules.dendritic`](https://github.com/vic/flake-file/tree/main/modules/dendritic).

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
- Exposes `packages.write-flake`.
- Exposes flake checks for generated files.

#### `flakeModules.dendritic`

- Includes flakeModules.default.
- Adds `flake-parts` input.
- Enables `flake.modules` option used in dendritic setups.
- Adds `import-tree` input.
- Sets `output` function to `import-tree ./modules`.
- Adds `treefmt-nix` input.
- Enables formatters: `nixfmt`, `deadnix`, and `nixf-diagnose`.
- Adds `allfollows` input.
- Enables flake.lock automatic flattening.

### Templates

#### `dendritic` template

A template for dendritic setups, includes `flakeModules.dendritic`.

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

Use `nix run .#write-flake` to generate. (Tip: you can install it as a shell hook for your devshell.)

---

## Available Options

Options are similar to the flake schema, with a simplified `follows` syntax. See below for details.

| Option                             | Description                       |
| ---------------------------------- | --------------------------------- |
| `flake-file.description`           | Sets the flake description        |
| `flake-file.nixConfig`             | Attrset for flake-level nixConfig |
| `flake-file.inputs.<name>.url`     | URL for a flake input             |
| `flake-file.inputs.<name>.flake`   | Boolean, is input a flake?        |
| `flake-file.inputs.<name>.follows` | Map of dependencies to follow     |

Example:

```nix
flake-file = {
  description = "my awesome flake";
  nixConfig = {}; # an attrset. currently not typed.
  inputs.<name>.url = "github:foo/bar";
  inputs.<name>.flake = false;
  # This is the only difference from real flake schema.
  # maps from `dependency-input` => `flake-input`.
  inputs.<name>.follows.nixpkgs = "nixpkgs";
};
```

#### About the `follows` Syntax

> **Note:** The `follows` syntax is improved for clarity.
>
> **Flake schema:**
>
> ```nix
> foo.inputs.bar.follows = "baz";
> ```
>
> **flake-file syntax:**
>
> ```nix
> foo.follows.bar = "baz";
> ```
>
> This change makes it easier to reason about and maintain input dependencies.

See also, [options.nix](https://github.com/vic/flake-file/blob/main/modules/options.nix).

---

## About the Flake `output` function

The `flake-file.output` option is a literal Nix expression. You cannot convert a Nix function value into a string for including in the generated flake file.

It defaults to:

```nix
inputs: import ./outputs.nix inputs
```

We recommend using this default, as it keeps your flake file focused on definitions of inputs and nixConfig. All Nix logic is moved to `outputs.nix`. Set this option only if you want to load another file with [a Nix one-liner](https://github.com/vic/flake-file/blob/main/modules/dendritic/dendritic.nix), but not for having a huge Nix code string in it.

---

## Automatic flake.lock flattening

Just add an [`allfollows`](https://github.com/spikespaz/allfollow) input:

```nix
flake-file.inputs.allfollows.url = "github:spikespaz/allfollow";
```

When `allfollows` is present in the `flake.nix` file,
`nix run .#write-flake` will automatically use `allfollow` to
flatten the `flake.lock` dependencies.

---

## Migration Guide

This section outlines recommended steps for adopting `flake-file` in your own repository.

1. **Prerequisite:** Ensure you have already adopted [flake-parts](https://flake.parts).
2. **Add Inputs:** In your current `flake.nix`, add the following two inputs:

   ```nix
   flake-file.url = "github:vic/flake-file";
   ```

3. **Move Outputs:** Copy the contents of your `outputs` function into a new file `outputs.nix`:

   ```nix
   # outputs.nix -- copied the `outputs` value in here.
   inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
     imports = [ ./inputs.nix ]; # Add this for step 4.
     # ... all your existing modules ...
   }
   ```

4. **Move Inputs:** Copy your current flake.nix file as a flake-parts module (e.g., `inputs.nix`):

   ```nix
   # flake-file.nix -- copied from flake.nix and adapted as a flake-parts module.
   { inputs, ... }:
   {
     imports = [
      inputs.flake-file.flakeModules.default # flake-file options.
     ];
     flake-file = {
       inputs = {
         flake-file.url = "github:vic/flake-file";
         # ... all your other flake inputs here.
         #
         # Update your dependencies follows from:
         #   foo.inputs.bar.follows = "baz";
         # into:
         #   foo.follows.bar = "baz";
         #
       };
       nixConfig = { }; # if you had any.
       description = "Your flake description";
     };
   }
   ```

5. **Backup:** Backup your flake.nix into flake.nix.bak before re-generating it.
6. **Generate:** Execute `nix run .#write-flake` to generate flake.nix from inputs.nix.
7. **Verify:** Check flake.nix and if everything is ok, remove the backup file.

You are done! Now you can move dependencies `flake-file.inputs.foo` from inputs.nix into any other imported module and `nix run .#write-flake` will take it.

---

## Development

```nix
# Run tests
nix flake check ./dev --override-input flake-file .

# Format
nix run ./dev#fmt

# Regenerate all flake.nix files in this repo.
nix run ./dev#regen
```

---

## Contributing & Support

- Found a bug or have a feature request? [Open an issue](https://github.com/vic/flake-file/issues).
- Contributions are welcome!

---

Made with <3 by [@vic](https://x.com/oeiuwq)
