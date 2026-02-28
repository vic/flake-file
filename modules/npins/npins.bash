cd "$out"
npins init --bare 2>/dev/null || true

SEEN_FILE=$(mktemp)
QUEUE_FILE=$(mktemp)
trap 'rm -f "$SEEN_FILE" "$QUEUE_FILE"' EXIT

# Pre-mark skipped inputs (follows="") as seen so they are never pinned.
printf '%s\n' "$skipSet" | grep -v '^$' >> "$SEEN_FILE" || true

# Seed the BFS queue with all declared inputs.
echo "$queueSeed" > "$QUEUE_FILE"

# Add a pin by its flake-style URL (github:o/r, gitlab:o/r, channel URL, etc.)
npins_add_url() {
    local name="$1" url="$2" spec owner repo ref channel
    case "$url" in
    github:*)
        spec="${url#github:}" owner="${spec%%/*}" spec="${spec#*/}"
        repo="${spec%%/*}" ref="${spec#*/}"
        if [ "$ref" != "$repo" ]; then
        npins add github --name "$name" -b "$ref" "$owner" "$repo"
        else
        # No explicit ref: prefer a release tag, fall back to common branches.
        npins add github --name "$name" "$owner" "$repo" 2>/dev/null \
            || npins add github --name "$name" -b main "$owner" "$repo" 2>/dev/null \
            || npins add github --name "$name" -b master "$owner" "$repo"
        fi ;;
    gitlab:*)
        spec="${url#gitlab:}" owner="${spec%%/*}" spec="${spec#*/}"
        repo="${spec%%/*}" ref="${spec#*/}"
        if [ "$ref" != "$repo" ]; then
        npins add gitlab --name "$name" -b "$ref" "$owner" "$repo"
        else
        npins add gitlab --name "$name" "$owner" "$repo" 2>/dev/null \
            || npins add gitlab --name "$name" -b main "$owner" "$repo" 2>/dev/null \
            || npins add gitlab --name "$name" -b master "$owner" "$repo"
        fi ;;
    https://channels.nixos.org/*|https://releases.nixos.org/*)
        channel=$(printf '%s' "$url" | sed 's|https://[^/]*/||;s|/.*||')
        npins add channel --name "$name" "$channel" ;;
    https://*|http://*)
        npins add tarball --name "$name" "$url" ;;
    *)
        npins add git --name "$name" "$url" ;;
    esac
}

# Fetch a github input's flake.nix and append its deps to QUEUE_FILE.
discover_transitive() {
    local name="$1" url="$2" spec owner repo ref
    [[ "$url" != github:* ]] && return 0
    spec="${url#github:}" owner="${spec%%/*}" spec="${spec#*/}"
    repo="${spec%%/*}" ref="${spec#*/}"
    [ "$ref" = "$repo" ] && ref="HEAD"

    local flake_tmp nix_tmp
    flake_tmp=$(mktemp --suffix=.nix)
    nix_tmp=$(mktemp --suffix=.nix)

    curl -sf "https://raw.githubusercontent.com/${owner}/${repo}/${ref}/flake.nix" \
    > "$flake_tmp" || { rm -f "$flake_tmp" "$nix_tmp"; return 0; }

    # Write a nix expression that extracts just the inputs URLs (no network at eval time).
    printf 'let f = import %s; norm = v: if builtins.isString v then v else v.url or ""; in builtins.mapAttrs (_: norm) (f.inputs or {})\n' \
    "$flake_tmp" > "$nix_tmp"

    nix-instantiate --eval --strict --json "$nix_tmp" 2>/dev/null \
    | jq -r 'to_entries[] | select(.value != "") | [.key, .value] | @tsv' \
    >> "$QUEUE_FILE" || true

    rm -f "$flake_tmp" "$nix_tmp"
}

# BFS: process queue items until none remain unvisited.
while true; do
    name="" url=""
    while IFS=$'\t' read -r qname qurl; do
    if ! grep -qxF "$qname" "$SEEN_FILE" 2>/dev/null; then
        name="$qname" url="$qurl"
        break
    fi
    done < "$QUEUE_FILE"
    [ -z "$name" ] && break
    printf '%s\n' "$name" >> "$SEEN_FILE"
    if ! jq -e --arg n "$name" '.pins | has($n)' npins/sources.json >/dev/null 2>&1; then
    npins_add_url "$name" "$url" || true
    fi
    discover_transitive "$name" "$url"
done

# Remove any pins that were not reachable in this run.
if [ -f npins/sources.json ]; then
    for existing in $(jq -r '.pins | keys[]' npins/sources.json); do
    if ! grep -qxF "$existing" "$SEEN_FILE"; then
        npins remove "$existing"
    fi
    done
fi