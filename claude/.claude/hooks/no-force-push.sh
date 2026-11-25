#!/usr/bin/env bash
# no-force-push.sh — PreToolUse(Bash) hook: block every force-push.
#
# Hard rule: never force-push. Blocks `git push` with --force, -f (alone or in
# a short-flag group such as -uf), --force-with-lease[=...], --force-if-includes,
# or a "+" refspec (git push origin +main). Handles `git -C <dir> push` and
# commands chained with ; && || |.
#
# To update a pushed branch, merge origin/main into it instead of rebasing,
# and ask for review before pushing.
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

if printf '%s' "$cmd" | python3 -I -c '
import re, shlex, sys

cmd = sys.stdin.read()
# git options that take a separate value before the subcommand.
VALUE_OPTS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path"}

def is_force(args):
    for a in args:
        if a in ("--force", "--force-if-includes") or a.startswith("--force-with-lease"):
            return True
        if a.startswith("-") and not a.startswith("--") and "f" in a[1:]:
            return True
        if a.startswith("+") and len(a) > 1:
            return True
    return False

for seg in re.split(r"\|\||&&|[;|\n]", cmd):
    try:
        toks = shlex.split(seg)
    except ValueError:
        toks = seg.split()
    for i, t in enumerate(toks):
        if t != "git" and not t.endswith("/git"):
            continue
        j = i + 1
        while j < len(toks) and toks[j].startswith("-"):
            j += 2 if toks[j] in VALUE_OPTS else 1
        if j < len(toks) and toks[j] == "push" and is_force(toks[j + 1:]):
            sys.exit(0)
sys.exit(1)
'; then
	printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force-push is blocked (hard rule: never force-push). To update a pushed branch, merge origin/main into it instead of rebasing, and ask for review before pushing."}}'
fi
exit 0
