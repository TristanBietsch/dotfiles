#!/usr/bin/env bash
# Tests for dotsync with throwaway repos: one bare "origin", two machine clones
# (A, B), a downstream clone (W) for route. No network, no signing.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
ROOT=$PWD
DOTSYNC=$ROOT/dotsync/.local/bin/dotsync
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0
ok() { echo "    ok    $*"; }
ko() { echo "    FAIL  $*"; fail=1; }
check() { if eval "$2"; then ok "$1"; else ko "$1"; fi; }

export GIT_CONFIG_GLOBAL=$tmp/gitconfig GIT_CONFIG_NOSYSTEM=1
git config --global user.name test
git config --global user.email test@example.com
git config --global commit.gpgsign false
git config --global init.defaultBranch master
git config --global advice.detachedHead false

printf '#!/usr/bin/env bash\necho "$*" >>%s/notes\n' "$tmp" >"$tmp/notify"
chmod +x "$tmp/notify"
export DOTSYNC_NOTIFY=$tmp/notify DOTSYNC_SKIP_TRUFFLEHOG=1 DOTSYNC_WORK=$tmp/nowork
export DOTSYNC_HOME=$tmp/home
mkdir -p "$DOTSYNC_HOME"
ds() { # ds <clone> <state> args...
	local c=$1 s=$2
	shift 2
	DOTSYNC_PUBLIC=$tmp/$c DOTSYNC_STATE=$tmp/state-$s "$DOTSYNC" "$@"
}

# seed
git init -q --bare "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/seed" 2>/dev/null
mkdir -p "$tmp/seed/scripts" "$tmp/seed/claude/.claude" "$tmp/seed/app/.config/app"
cp "$ROOT/scripts/jq-merge3" "$tmp/seed/scripts/"
cp "$ROOT/.gitattributes" "$tmp/seed/"
printf 'app/.config/app/settings.json\n' >"$tmp/seed/scripts/drift-allow.txt"
printf 'a\tr/a\tp\tsha\t-\n' >"$tmp/seed/claude/.claude/skills.tsv"
printf '{\n  "x": 1,\n  "y": 1\n}\n' >"$tmp/seed/claude/.claude/settings.json"
printf 'line1\nline2\n' >"$tmp/seed/notes.txt"
printf 'keep\n' >"$tmp/seed/other.txt"
printf '{"theme": "dark"}\n' >"$tmp/seed/app/.config/app/settings.json"
git -C "$tmp/seed" add -A && git -C "$tmp/seed" commit -qm seed && git -C "$tmp/seed" push -q origin master
for m in A B; do git clone -q "$tmp/origin.git" "$tmp/$m"; done

echo "  dotsync"
# 1 lock
mkdir -p "$tmp/state-A/lock" && echo $$ >"$tmp/state-A/lock/pid"
ds A A run --quiet
check "second run exits 3 while lock is held" "[[ $? == 3 ]]"
rm -rf "$tmp/state-A/lock"

# 2 union merge of skills.tsv + push
printf 'b\tr/b\tp\tsha\t-\n' >>"$tmp/A/claude/.claude/skills.tsv" && git -C "$tmp/A" commit -qam "add b"
printf 'c\tr/c\tp\tsha\t-\n' >>"$tmp/B/claude/.claude/skills.tsv" && git -C "$tmp/B" commit -qam "add c"
ds A A run --quiet
ds B B run --quiet
git -C "$tmp/seed" pull -q
check "skills.tsv rows from both machines kept (union)" "[[ \$(grep -c . $tmp/seed/claude/.claude/skills.tsv) == 3 ]]"

# 3 settings.json 3-way key merge
ds A A run --quiet >/dev/null
jq '.x = 2' "$tmp/A/claude/.claude/settings.json" >"$tmp/j" && mv "$tmp/j" "$tmp/A/claude/.claude/settings.json" && git -C "$tmp/A" commit -qam x2
jq '.y = 3' "$tmp/B/claude/.claude/settings.json" >"$tmp/j" && mv "$tmp/j" "$tmp/B/claude/.claude/settings.json" && git -C "$tmp/B" commit -qam y3
ds A A run --quiet
ds B B run --quiet
check "settings.json: different keys from both machines merged" "[[ \$(jq -c '[.x,.y]' $tmp/B/claude/.claude/settings.json) == '[2,3]' ]]"

# 4 autostash carries uncommitted edits
ds A A run --quiet
printf 'more\n' >>"$tmp/A/other.txt" && git -C "$tmp/A" commit -qam other && ds A A run --quiet
printf 'wip\n' >>"$tmp/B/notes.txt"
ds B B run --quiet
check "uncommitted edit survives pull (autostash)" "grep -q wip $tmp/B/notes.txt && [[ \$(git -C $tmp/B rev-parse HEAD) == \$(git -C $tmp/B rev-parse origin/master) ]]"
git -C "$tmp/B" checkout -q -- notes.txt

# 5 real conflict parks, master untouched, notification
sed -i.x 's/line1/A-edit/' "$tmp/A/notes.txt" && rm -f "$tmp/A/notes.txt.x" && git -C "$tmp/A" commit -qam A && ds A A run --quiet
sed -i.x 's/line1/B-edit/' "$tmp/B/notes.txt" && rm -f "$tmp/B/notes.txt.x" && git -C "$tmp/B" commit -qam B
before=$(git -C "$tmp/B" rev-parse HEAD)
ds B B run --quiet
check "conflict: bookmark branch created" "[[ -n \$(git -C $tmp/B branch --list 'conflict/*') ]]"
check "conflict: master unchanged, no rebase left open" "[[ \$(git -C $tmp/B rev-parse HEAD) == $before && ! -d $tmp/B/.git/rebase-merge ]]"
check "conflict: notification sent" "grep -q 'conflict during rebase' $tmp/notes"
git -C "$tmp/B" reset -q --hard origin/master

# 6 drift adoption: app replaced its link with a real file
ds A A run --quiet
stow -d "$tmp/A" -t "$DOTSYNC_HOME" --no-folding app
live=$DOTSYNC_HOME/.config/app/settings.json
rm "$live" && printf '{"theme": "light"}\n' >"$live"
ds A A run --quiet
check "drift: change committed and pushed" "git -C $tmp/A log -1 --format=%s | grep -q 'adopt live changes' && [[ \$(git -C $tmp/A rev-parse HEAD) == \$(git -C $tmp/A rev-parse origin/master) ]]"
check "drift: live file is a link again with the new content" "[[ -L $live ]] && grep -q light $live"

# 7 dirty reminder
printf 'x\n' >>"$tmp/A/other.txt"
DOTSYNC_DIRTY_HOURS=0 ds A A run --quiet
check "dirty: reminder sent" "grep -q 'uncommitted changes' $tmp/notes"
git -C "$tmp/A" checkout -q -- other.txt

# 8 route: downstream commit to public, scans first
git clone -q "$tmp/origin.git" "$tmp/W"
git -C "$tmp/W" remote rename origin upstream
git init -q --bare "$tmp/work.git"
git -C "$tmp/W" remote add origin "$tmp/work.git"
mkdir -p "$tmp/W/work" "$tmp/W/layer"
printf '#!/bin/sh\n' >"$tmp/W/work/sync.sh"
printf 'layer/\nwork/\n' >"$tmp/W/work/layer-paths"
printf 'secretcorp\n' >"$tmp/W/work/public-deny.txt"
git -C "$tmp/W" add -A && git -C "$tmp/W" commit -qm work && git -C "$tmp/W" push -q origin master
git -C "$tmp/W" fetch -q origin
export DOTSYNC_WORK=$tmp/W
printf 'secretcorp\n' >>"$tmp/W/other.txt" && git -C "$tmp/W" commit -qam leak
DOTSYNC_YES=y ds A A route HEAD >/dev/null 2>&1
check "route: refuses a patch with a private term" "[[ \$? != 0 ]] && ! grep -q secretcorp $tmp/A/other.txt"
git -C "$tmp/W" reset -q --hard HEAD~1
printf 'fine\n' >>"$tmp/W/other.txt" && printf 'x\n' >"$tmp/W/layer/f" && git -C "$tmp/W" add -A && git -C "$tmp/W" commit -qm mixed
DOTSYNC_YES=y ds A A route HEAD >/dev/null 2>&1
check "route: refuses a commit mixing layer and base files" "[[ \$? != 0 ]]"
git -C "$tmp/W" reset -q --hard HEAD~1
printf 'fine\n' >>"$tmp/W/other.txt" && git -C "$tmp/W" commit -qam "clean base change"
DOTSYNC_YES=y ds A A route HEAD >/dev/null 2>&1
check "route: clean change lands in public and is pushed" "grep -q fine $tmp/A/other.txt && [[ \$(git -C $tmp/A rev-parse HEAD) == \$(git -C $tmp/A rev-parse origin/master) ]]"
check "route: commit dropped downstream" "[[ \$(git -C $tmp/W log -1 --format=%s) == work ]]"

exit "$fail"
