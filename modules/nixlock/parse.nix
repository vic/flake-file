lib:
let

  parseRef =
    urlWithParams:
    let
      pairs = builtins.filter (lib.hasPrefix "ref=") (
        lib.splitString "&" (lib.last (lib.splitString "?" urlWithParams))
      );
    in
    if pairs != [ ] then lib.removePrefix "ref=" (builtins.head pairs) else "HEAD";

  baseUrl = urlWithParams: builtins.head (lib.splitString "?" urlWithParams);

  parseGitHost =
    base: path:
    let
      parts = lib.splitString "/" path;
      owner = builtins.elemAt parts 0;
      repo = builtins.elemAt parts 1;
      ref = if builtins.length parts > 2 then builtins.elemAt parts 2 else "HEAD";
    in
    {
      type = "gitArchive";
      url = "${base}/${owner}/${repo}";
      inherit ref;
    };

  parseGithub = parseGitHost "https://github.com";
  parseGitlab = parseGitHost "https://gitlab.com";
  parseSourcehut = parseGitHost "https://git.sr.ht";

  parseGitUrl = urlWithParams: {
    type = "git";
    url = baseUrl urlWithParams;
    ref = parseRef urlWithParams;
  };

  attrsetBases = input: {
    github = "https://github.com";
    gitlab = "https://${input.host or "gitlab.com"}";
    sourcehut = "https://${input.host or "git.sr.ht"}";
  };

  attrsetToNixlock =
    input:
    let
      mgithost = (attrsetBases input).${input.type} or null;
    in
    if mgithost != null then
      {
        type = "gitArchive";
        url = "${mgithost}/${input.owner}/${input.repo}";
        ref = input.ref or "HEAD";
      }
    else if input.type == "git" then
      {
        type = "git";
        url = input.url;
        ref = input.ref or "HEAD";
      }
    else if
      lib.elem input.type [
        "tarball"
        "file"
      ]
    then
      {
        type = "archive";
        url = input.url;
      }
    else
      null;

  flakeUrlToNixlock =
    url:
    let
      scheme = builtins.head (lib.splitString ":" url);
      rest = lib.concatStringsSep ":" (builtins.tail (lib.splitString ":" url));
    in
    if scheme == "github" then
      parseGithub rest
    else if scheme == "gitlab" then
      parseGitlab rest
    else if scheme == "sourcehut" then
      parseSourcehut rest
    else if lib.hasPrefix "git+" url then
      parseGitUrl (lib.removePrefix "git+" url)
    else if lib.hasPrefix "tarball+" url then
      flakeUrlToNixlock (lib.removePrefix "tarball+" url)
    else if lib.hasPrefix "file+" url then
      flakeUrlToNixlock (lib.removePrefix "file+" url)
    else if lib.hasPrefix "http" url then
      {
        type = "archive";
        inherit url;
      }
    else
      null;

  toNixlockInput =
    _name: input:
    if input ? url then
      flakeUrlToNixlock input.url
    else if input ? type then
      attrsetToNixlock input
    else
      null;

in
{
  inherit toNixlockInput;
}
