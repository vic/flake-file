# Pure Nix flake URL parser. Returns a structured attrset for any flake URL.
# Covers all types defined in the Nix flake reference spec.
lib:
let
  splitFirst =
    sep: s:
    let
      parts = lib.splitString sep s;
    in
    {
      head = lib.head parts;
      tail = lib.concatStringsSep sep (lib.tail parts);
    };

  queryParam =
    key: queryStr:
    let
      pairs = if queryStr == "" then [ ] else lib.splitString "&" queryStr;
      m = lib.filter (lib.hasPrefix "${key}=") pairs;
    in
    if m == [ ] then "" else lib.removePrefix "${key}=" (lib.head m);

  parseUrl =
    rawUrl:
    let
      q = splitFirst "?" rawUrl;
      base = q.head;
      queryStr = q.tail;
      param = key: queryParam key queryStr;

      s = splitFirst ":" base;
      scheme = s.head;
      rest = s.tail;

      decodeSlash = lib.replaceStrings [ "%2F" "%2f" ] [ "/" "/" ];

      parseOwnerRepo =
        path:
        let
          parts = lib.splitString "/" (decodeSlash path);
          owner = lib.elemAt parts 0;
          repo = if lib.length parts > 1 then lib.elemAt parts 1 else "";
          pathRef = if lib.length parts > 2 then lib.concatStringsSep "/" (lib.drop 2 parts) else "";
        in
        {
          inherit owner repo pathRef;
        };

      inferType =
        if
          lib.elem scheme [
            "github"
            "gitlab"
            "sourcehut"
            "indirect"
            "path"
            "tarball"
            "file"
          ]
        then
          scheme
        else if
          lib.elem scheme [
            "git"
            "git+https"
            "git+http"
            "git+ssh"
            "git+git"
            "git+file"
          ]
        then
          "git"
        else if
          lib.elem scheme [
            "hg"
            "hg+https"
            "hg+http"
            "hg+ssh"
            "hg+file"
          ]
        then
          "mercurial"
        else if
          lib.elem scheme [
            "tarball+https"
            "tarball+http"
            "tarball+file"
          ]
        then
          "tarball"
        else if
          lib.elem scheme [
            "file+https"
            "file+http"
            "file+file"
          ]
        then
          "file"
        else if
          lib.hasSuffix ".tar.gz" base
          || lib.hasSuffix ".tar.xz" base
          || lib.hasSuffix ".tgz" base
          || lib.hasSuffix ".tar.bz2" base
          || lib.hasSuffix ".tar.zst" base
          || lib.hasSuffix ".zip" base
        then
          "tarball"
        else
          "indirect";

      type = inferType;

      ghgl = owner: repo: pathRef: defHost: {
        inherit type;
        owner = owner;
        repo = repo;
        ref =
          let
            r = param "ref";
          in
          if r != "" then r else pathRef;
        rev = param "rev";
        host =
          let
            h = param "host";
          in
          if h != "" then h else defHost;
        dir = param "dir";
        url = "";
      };

      p = parseOwnerRepo rest;

    in
    if type == "github" then
      ghgl p.owner p.repo p.pathRef "github.com"
    else if type == "gitlab" then
      ghgl p.owner p.repo p.pathRef "gitlab.com"
    else if type == "sourcehut" then
      let
        p2 = parseOwnerRepo rest;
        owner = lib.removePrefix "~" p2.owner;
      in
      {
        inherit type;
        owner = owner;
        repo = p2.repo;
        ref =
          let
            r = param "ref";
          in
          if r != "" then r else p2.pathRef;
        rev = param "rev";
        host =
          let
            h = param "host";
          in
          if h != "" then h else "git.sr.ht";
        dir = "";
        url = "";
      }
    else if type == "git" then
      {
        inherit type;
        owner = "";
        repo = "";
        ref = param "ref";
        rev = param "rev";
        host = "";
        dir = param "dir";
        url = "${scheme}:${rest}";
      }
    else if type == "mercurial" then
      {
        inherit type;
        owner = "";
        repo = "";
        ref = param "ref";
        rev = param "rev";
        host = "";
        dir = "";
        url = "${scheme}:${rest}";
      }
    else if type == "tarball" then
      {
        inherit type;
        owner = "";
        repo = "";
        ref = "";
        rev = "";
        host = "";
        dir = "";
        url =
          if
            lib.elem scheme [
              "tarball+https"
              "tarball+http"
              "tarball+file"
            ]
          then
            lib.removePrefix "tarball+" rawUrl
          else
            rawUrl;
      }
    else if type == "file" then
      {
        inherit type;
        owner = "";
        repo = "";
        ref = "";
        rev = "";
        host = "";
        dir = "";
        url =
          if
            lib.elem scheme [
              "file+https"
              "file+http"
              "file+file"
            ]
          then
            lib.removePrefix "file+" rawUrl
          else
            rawUrl;
      }
    else if type == "path" then
      {
        inherit type;
        owner = "";
        repo = "";
        ref = "";
        rev = "";
        host = "";
        dir = "";
        url = rawUrl;
      }
    else
      {
        type = "indirect";
        owner = "";
        repo = "";
        ref = "";
        rev = "";
        host = "";
        dir = "";
        url = rawUrl;
      };

in
parseUrl
