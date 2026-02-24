# npins

This template is an example of using `flake-file.inputs` in a non-flakes
project with [npins](https://github.com/andir/npins).

It uses npins to pin and fetch inputs defined as options inside `./modules`.

## Update npins

Update the `npins/` directory from your declared inputs:

```shell
nix-shell . -A npins.env --run write-npins
```

This will run `npins add` for
each input declared in your modules, using the correct npins subcommand
(`github`, `tarball`, `git`, etc.) based on the input URL scheme.
