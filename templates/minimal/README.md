This template is an example of how to use flake-file without introducing new dependencies
to your existing flake.

This flake is the result of doing this bootstrap step (taken form the guide):

```shell
mv flake.nix flake-file.nix
nix-shell https://github.com/vic/flake-file/archive/main.tar.gz \
  -A flake-file.sh --run write-flake \
  --arg modules ./flake-file.nix --argstr outputs flake-file
```
