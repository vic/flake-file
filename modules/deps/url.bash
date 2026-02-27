# Extract a query parameter value from a URL: url_param KEY URL
url_param() {
  local key="$1" url="$2" qs
  qs="${url#*\?}"
  [ "$qs" = "$url" ] && { printf ''; return; }
  printf '%s' "$qs" | tr '&' '\n' | grep "^${key}=" | cut -d= -f2- | head -1
}

url_base()   { printf '%s' "${1%%\?*}"; }
url_decode() { printf '%s' "$1" | sed 's/%2[Ff]/\//g'; }

# Resolve a git ref to exact commit SHA (deref tags, fallback to ref as-is).
git_rev() {
  local remote="$1" ref="$2" resolved deref
  resolved=$(git ls-remote "$remote" \
    "refs/heads/$ref" "refs/tags/$ref" "HEAD" 2>/dev/null \
    | grep -v '\^{}' | awk 'NR==1{print $1; exit}')
  deref=$(git ls-remote "$remote" "refs/tags/$ref^{}" 2>/dev/null | awk '{print $1; exit}')
  printf '%s' "${deref:-${resolved:-$ref}}"
}

# Fetch sha256 for a tarball URL (nix-prefetch-url --unpack).
prefetch_tarball() { nix-prefetch-url --unpack "$1" 2>/dev/null; }

# Progress output to stderr.
log_info() { printf '[deps] %s\n' "$*" >&2; }

# Emit a rich Nix attrset record.
# Usage: emit_record NAME OUTPATH_NIX_EXPR [key=value ...]
emit_record() {
  local name="$1" outpath="$2"
  shift 2
  printf '  %s = {\n    outPath = %s;\n' "$name" "$outpath"
  local kv k v
  for kv in "$@"; do
    k="${kv%%=*}" v="${kv#*=}"
    [ -n "$v" ] && printf '    %s = "%s";\n' "$k" "$v"
  done
  printf '  };\n'
}
