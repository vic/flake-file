# Unflake

This template is an example of using `flake-file.inputs` in a non-flakes project.

It uses [unflake](https://codeberg.org/goldstein/unflake) to pin and fetch inputs defined as options inside `./modules`.

## Generate `unflake.nix`

The following command is a convenience for generating `unflake.nix` by
first producing a temporary `inputs.nix` from your config and then
running unflake on it.

```shell
nix-shell . -A unflake.env --run write-unflake
```

You can also pass any unflake option:

```shell
nix-shell . -A unflake.env --run 'write-unflake --verbose --backend nix'
```

If you need to see the file that is being passed as `--inputs inputs.nix`
to the unflake command, you can generate it with:

```shell
# (only recommended for debugging)
nix-shell . -A unflake.env --run write-inputs

# then, you can run unflake yourself:
nix-shell https://ln-s.sh/unflake -A unflake-shell --run unflake
```

## Using with [npins](https://github.com/andir/npins)

Unflake has an npins backend to use it run:

```shell
nix-shell . -A unflake.env --run 'write-unflake --backend npins'
```
