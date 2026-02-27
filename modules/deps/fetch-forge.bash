fetch_github() {
  local name="$1" raw="$2"
  local body host dir rev ref owner repo sha256 outpath_nix
  body="$(url_base "${raw#github:}")"
  host="$(url_param host "$raw")"; host="${host:-github.com}"
  dir="$(url_param dir "$raw")"
  rev="$(url_param rev "$raw")"
  owner="${body%%/*}"; body="${body#*/}"
  repo="${body%%/*}"; ref="${body#"$repo"}"; ref="${ref#/}"
  [ -n "$rev" ] || rev=$(git_rev "https://${host}/${owner}/${repo}.git" "${ref:-HEAD}")
  local archive="https://${host}/${owner}/${repo}/archive/${rev}.tar.gz"
  log_info "fetching ${name} (github ${owner}/${repo} @ ${rev:0:12})"
  sha256=$(prefetch_tarball "$archive") || { log_info "warning: failed $name"; return 1; }
  if [ -n "$dir" ]; then
    outpath_nix="(builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }) + \"/$dir\""
  else
    outpath_nix="builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }"
  fi
  emit_record "$name" "$outpath_nix" \
    "type=github" "owner=$owner" "repo=$repo" "rev=$rev" "ref=$ref" "host=$host" "dir=$dir"
}

fetch_gitlab() {
  local name="$1" raw="$2"
  local body host dir rev ref owner repo sha256 archive
  body="$(url_base "${raw#gitlab:}")"
  host="$(url_param host "$raw")"; host="${host:-gitlab.com}"
  dir="$(url_param dir "$raw")"
  rev="$(url_param rev "$raw")"
  owner="$(url_decode "${body%%/*}")"; body="${body#*/}"
  repo="${body%%/*}"; ref="${body#"$repo"}"; ref="${ref#/}"
  [ -n "$rev" ] || rev=$(git_rev "https://${host}/${owner}/${repo}.git" "${ref:-HEAD}")
  archive="https://${host}/${owner}/${repo}/-/archive/${rev}/${repo}-${rev}.tar.gz"
  log_info "fetching ${name} (gitlab ${owner}/${repo} @ ${rev:0:12})"
  local sha256
  sha256=$(prefetch_tarball "$archive") || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }" \
    "type=gitlab" "owner=$owner" "repo=$repo" "rev=$rev" "ref=$ref" "host=$host"
}

fetch_sourcehut_hg() {
  local name="$1" raw="$2"
  local body host rev owner repo ref remote sha256 archive
  host="$(url_param host "$raw")"; host="${host:-hg.sr.ht}"
  body="$(url_base "${raw#sourcehut:}")"
  rev="$(url_param rev "$raw")"
  owner="${body%%/*}"; owner="${owner#\~}"
  body="${body#*/}"; repo="${body%%/*}"; ref="${body#"$repo"}"; ref="${ref#/}"
  remote="https://${host}/~${owner}/${repo}"
  [ -n "$rev" ] || rev=$(curl -sfL "${remote}/log/${ref:-tip}/rss" \
    | grep -m1 '<guid>' | sed 's|.*<guid>.*rev=\([^<]*\).*|\1|')
  archive="${remote}/archive/${rev}.tar.gz"
  log_info "fetching ${name} (sourcehut-hg ${owner}/${repo} @ ${rev:0:12})"
  sha256=$(prefetch_tarball "$archive") || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }" \
    "type=sourcehut" "owner=$owner" "repo=$repo" "rev=$rev" "ref=$ref" "host=$host"
}

fetch_sourcehut() {
  local name="$1" raw="$2"
  local body host ref rev owner repo remote sha256 archive
  host="$(url_param host "$raw")"; host="${host:-git.sr.ht}"
  body="$(url_base "${raw#sourcehut:}")"
  rev="$(url_param rev "$raw")"
  owner="${body%%/*}"; owner="${owner#\~}"
  body="${body#*/}"; repo="${body%%/*}"; ref="${body#"$repo"}"; ref="${ref#/}"
  remote="https://${host}/~${owner}/${repo}"
  [ -n "$rev" ] || rev=$(git_rev "${remote}" "${ref:-HEAD}")
  archive="${remote}/archive/${rev}.tar.gz"
  log_info "fetching ${name} (sourcehut ${owner}/${repo} @ ${rev:0:12})"
  sha256=$(prefetch_tarball "$archive") || { log_info "warning: failed $name"; return 1; }
  emit_record "$name" "builtins.fetchTarball { url = \"$archive\"; sha256 = \"$sha256\"; }" \
    "type=sourcehut" "owner=$owner" "repo=$repo" "rev=$rev" "ref=$ref" "host=$host"
}
