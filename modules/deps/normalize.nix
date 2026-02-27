flakeFile:
let
  f = import flakeFile;

  withRef =
    owner: repo: ref:
    "${owner}/${repo}${if ref != "" then "/" + ref else ""}";
  withHost = host: def: if host != "" && host != def then "?host=${host}" else "";

  refOf = v: if v ? rev then v.rev else (v.ref or "");

  github = v: "github:${withRef v.owner v.repo (refOf v)}${withHost (v.host or "") "github.com"}";
  gitlab = v: "gitlab:${withRef v.owner v.repo (refOf v)}${withHost (v.host or "") "gitlab.com"}";
  sourcehut =
    v: "sourcehut:~${withRef v.owner v.repo (refOf v)}${withHost (v.host or "") "git.sr.ht"}";

  gitParams =
    v:
    let
      ref = if v ? ref then "ref=${v.ref}" else "";
      rev = if v ? rev then "rev=${v.rev}" else "";
      params = builtins.filter (s: s != "") [
        ref
        rev
      ];
    in
    if params == [ ] then "" else "?" + builtins.concatStringsSep "&" params;

  fromAttrs =
    v:
    if !(v ? type) then
      (v.url or "")
    else if v.type == "github" then
      github v
    else if v.type == "gitlab" then
      gitlab v
    else if v.type == "sourcehut" then
      sourcehut v
    else if v.type == "git" then
      "${v.url or ""}${gitParams v}"
    else if v.type == "tarball" then
      v.url or ""
    else if v.type == "file" then
      v.url or ""
    else if v.type == "path" then
      "path:${v.path or ""}"
    else if v.type == "indirect" then
      v.id or ""
    else if v.type == "mercurial" then
      v.url or ""
    else
      "";

  norm =
    v:
    if builtins.isString v then
      v
    else if v ? url then
      v.url
    else if v ? follows then
      ""
    else
      fromAttrs v;

in
builtins.mapAttrs (_: norm) (f.inputs or { })
