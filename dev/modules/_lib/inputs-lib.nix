lib: esc: inputs:
let
  pinnableInputs = lib.filterAttrs (_: v: v.url or "" != "") inputs;
  followsInputs = lib.filterAttrs (_: v: v.url or "" == "") inputs;

  seedBlock =
    entries: mkLine:
    let
      cmds = lib.mapAttrsToList mkLine entries;
    in
    if cmds == [ ] then ":" else "{\n" + lib.concatStringsSep "\n" cmds + "\n}";

  followsSeed =
    seedBlock followsInputs (name: _: "  printf '%s\\n' ${esc name}") + " >> \"$FOLLOWS_FILE\"";

  queueSeed =
    seedBlock pinnableInputs (name: input: "  printf '%s\\t%s\\n' ${esc name} ${esc (input.url or "")}")
    + " >> \"$QUEUE_FILE\"";

in
{
  inherit
    pinnableInputs
    followsInputs
    followsSeed
    queueSeed
    ;
}
