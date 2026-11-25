#!/usr/bin/env bash
# no-force-push.sh — PreToolUse(Bash) hook: block every force-push.
#
# Hard rule: never force-push. Blocks `git push` with --force, -f (alone or in
# a short-flag group such as -uf), --force-with-lease[=...], --force-if-includes,
# or a "+" refspec (git push origin +main). Handles `git -C <dir> push` and
# commands chained with ; && || |. Deliberately coarse and fail-closed: any
# command mentioning git and push is denied if a force signal (incl. abbreviated
# --fo..., --mirror, -c remote.*.push/+refspec) appears anywhere in it, however
# it is wrapped (bash -c, eval, $(...), xargs, aliases).
#
# To update a pushed branch, merge origin/main into it instead of rebasing,
# and ask for review before pushing.
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

if printf '%s' "$cmd" | python3 -I -c '
import re, sys

cmd = sys.stdin.read()
# Strip quotes and backslashes first, so g"i"t or pu\\sh cannot hide the words.
cmd = re.sub(r"[\"\x27\\\\]", "", cmd)
# Deliberately coarse and fail-closed: no attempt to parse shell or git
# options precisely. Any command that mentions both git and push is denied
# if a force signal appears anywhere in it. A push chained with an unrelated
# -f flag (rm -f) is blocked too; run those as separate commands.
if not (re.search(r"\bgit\b", cmd) and re.search(r"\bpush\b", cmd)):
    sys.exit(1)
FORCE = [
    r"--fo[a-z-]*",                         # --force, --force-with-lease, --force-if-includes and abbreviations
    r"--mi[a-z]*",                          # --mirror and abbreviations; implies force
    r"(^|[\s\"=])-[A-Za-z]*f[A-Za-z]*\b",   # -f, -uf, -fu
    r"(^|[\s\"=:])\+[^\s:+]",               # +refspec, also inside -c remote.x.push=+...
    r"remote\.[^\s=]*\.(push|mirror)\b",    # refspec or mirror set through git -c / --config-env
    r"\bpush\.default\b",
]
sys.exit(0 if any(re.search(f, cmd) for f in FORCE) else 1)
'; then
	printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force-push is blocked (hard rule: never force-push). To update a pushed branch, merge origin/main into it instead of rebasing, and ask for review before pushing."}}'
fi
exit 0
