# Nixlock

This template is an example of using `flake-file.inputs` in a non-flakes project.

It uses [nixlock](https://codeberg.org/FrdrCkII/nixlock) to pin and fetch inputs defined as options inside `./modules`.

## Generate nixlock

The following command is a convenience for generating `nixlock.lock.nix`:

```shell
nix-shell . -A flake-file.sh --run write-nixlock
```

You can also the `update` command.

```shell
nix-shell . -A flake-file.sh --run 'write-nixlock update'
```
