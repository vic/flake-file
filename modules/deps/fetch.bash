fetch_git_url() {
  local name="$1" raw="$2"
  local url ref rev
  url="$(url_base "$raw")"; url="${url#git+}"
  ref="$(url_param ref "$raw")"
  rev="$(url_param rev "$raw")"
  [ -n "$rev" ] || rev=$(git_rev "$url" "${ref:-HEAD}")
  log_info "fetching ${name} (git ${url} @ ${rev:0:12})"
  emit_record "$name" "builtins.fetchGit { url = \"$url\"; rev = \"$rev\"; }" \
    "type=git" "url=$url" "rev=$rev" "ref=$ref"
}

fetch_tarball_url() {
  local name="$1" raw="$2" url sha256
  url="$(url_base "$raw")"; url="${url#tarball+}"
  log_info "fetching ${name} (tarball)"
  sha256=$(prefetch_tarball "$url") || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchTarball { url = \"$url\"; sha256 = \"$sha256\"; }" \
    "type=tarball" "url=$url"
}

fetch_file_url() {
  local name="$1" raw="$2" url sha256
  url="$(url_base "$raw")"; url="${url#file+}"
  log_info "fetching ${name} (file)"
  sha256=$(nix-prefetch-url "$url" 2>/dev/null) || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchurl { url = \"$url\"; sha256 = \"$sha256\"; }" \
    "type=file" "url=$url"
}

fetch_mercurial() {
  local name="$1" raw="$2" url ref rev sha256 archive
  url="$(url_base "$raw")"; url="${url#hg+}"
  ref="$(url_param ref "$raw")"
  rev="$(url_param rev "$raw")"
  [ -n "$rev" ] || rev=$(curl -sfL "${url}/log/${ref:-tip}/rss" \
    | grep -m1 '<guid>' | sed 's|.*<guid>.*rev=\([^<]*\).*|\1|')
  archive="${url}/archive/${rev}.tar.gz"
  log_info "fetching ${name} (mercurial @ ${rev:0:12})"
  sha256=$(prefetch_tarball "$archive") || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }" \
    "type=mercurial" "url=$url" "rev=$rev" "ref=$ref"
}

fetch_entry() {
  local name="$1" url="$2"
  case "$url" in
    github:*)     fetch_github        "$name" "$url" ;;
    gitlab:*)     fetch_gitlab        "$name" "$url" ;;
    sourcehut:*hg.sr.ht*) fetch_sourcehut_hg "$name" "$url" ;;
    sourcehut:*)  fetch_sourcehut     "$name" "$url" ;;
    git+http://*|git+https://*|git+ssh://*|git+git://*|git+file://*)
                  fetch_git_url      "$name" "$url" ;;
    git://*)      fetch_git_url      "$name" "git+${url}" ;;
    hg+*)         fetch_mercurial    "$name" "$url" ;;
    tarball+*)    fetch_tarball_url  "$name" "$url" ;;
    file+*)       fetch_file_url     "$name" "$url" ;;
    *.tar.gz|*.tar.bz2|*.tar.xz|*.tar.zst|*.zip|http://*|https://*)
                  fetch_tarball_url  "$name" "$url" ;;
    path:*)       log_info "skipping ${name} (local path)" ;;
    *)            log_info "skipping ${name} (indirect/unknown: $url)" ;;
  esac
}

discover_transitive() {
  local name="$1" url="$2"
  [[ "$url" != github:* ]] && return 0
  local spec owner repo ref flake_tmp expr_tmp
  spec="${url#github:}" owner="${spec%%/*}" spec="${spec#*/}"
  repo="${spec%%/*}" ref="${spec#*/}"
  [ "$ref" = "$repo" ] && ref="HEAD"
  flake_tmp=$(mktemp --suffix=.nix)
  expr_tmp=$(mktemp --suffix=.nix)
  curl -sf "https://raw.githubusercontent.com/${owner}/${repo}/${ref}/flake.nix" \
    > "$flake_tmp" || { rm -f "$flake_tmp" "$expr_tmp"; return 0; }
  printf '(import %s) %s\n' "$NORMALIZE_NIX" "$flake_tmp" > "$expr_tmp"
  nix-instantiate --eval --strict --json "$expr_tmp" 2>/dev/null \
    | jq -r 'to_entries[] | select(.value | . != "" and test("^[a-z]")) | [.key, .value] | @tsv' \
    >> "$QUEUE_FILE" || true
  rm -f "$flake_tmp" "$expr_tmp"
}
