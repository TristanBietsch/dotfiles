#!/usr/bin/env bash
# link.sh per-machine files: seeded on a fresh $HOME, link replaced by a real
# copy (content kept), never overwritten afterwards.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
command -v stow >/dev/null || { echo "    skip  per-machine (no stow)"; exit 0; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0
check() { if eval "$2"; then echo "    ok    $1"; else echo "    FAIL  $1"; fail=1; fi; }
f=.gemini/antigravity-cli/settings.json
run() { HOME=$tmp GIT_CONFIG_GLOBAL=/dev/null ./scripts/link.sh >/dev/null 2>&1; }

echo "  per-machine"
run
check "fresh machine: seeded as a real file" "[[ -f $tmp/$f && ! -L $tmp/$f ]] && cmp -s $tmp/$f agy/$f"
printf '{"mine":1}\n' >"$tmp/$f"
run
check "existing per-machine file never overwritten" "grep -q mine $tmp/$f"
printf '{"linked":1}\n' >"$tmp/linked.json"
rm "$tmp/$f" && ln -s "$tmp/linked.json" "$tmp/$f"
run
check "old link replaced by a real copy of its content" "[[ ! -L $tmp/$f ]] && grep -q linked $tmp/$f"
check "gitconfig: seeded as a real file" "[[ -f $tmp/.gitconfig && ! -L $tmp/.gitconfig ]]"
check "gitconfig: os fragments still linked" "[[ -L $tmp/.config/git/os/darwin.gitconfig ]]"
exit "$fail"
