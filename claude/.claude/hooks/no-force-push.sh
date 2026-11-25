#!/usr/bin/env bash
# no-force-push.sh — PreToolUse(Bash) hook: block every force-push.
#
# Hard rule: never force-push. Blocks `git push` with --force, -f (alone or in
# a short-flag group such as -uf), --force-with-lease[=...], --force-if-includes,
# or a "+" refspec (git push origin +main). Handles `git -C <dir> push` and
# commands chained with ; && || |. Commands wrapped in bash -c, eval, $(...),
# backticks, xargs or a git alias are judged on their raw text, and a command
# that fails to parse is denied if it looks like a forced push (fail closed).
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
FORCE_TOKEN = re.compile(r"(^|[\s\"=])(--force(-with-lease|-if-includes)?\b|-[A-Za-z]*f[A-Za-z]*\b|\+[^\s:+]+)")
# Shapes this parser cannot see through: nested shells, eval, command
# substitution, xargs, git aliases. With any of these, judge the raw text.
OPAQUE = re.compile(r"\b(ba|z|da|k)?sh\s+-\w*c\b|\beval\b|\$\(|`|\bxargs\b|alias\.|\bexec\b")

def is_force(args):
    for a in args:
        if a in ("--force", "--force-if-includes") or a.startswith("--force-with-lease"):
            return True
        if a.startswith("-") and not a.startswith("--") and "f" in a[1:]:
            return True
        if a.startswith("+") and len(a) > 1:
            return True
    return False

def raw_force(text):
    return bool(re.search(r"\bpush\b", text) and FORCE_TOKEN.search(text))

if OPAQUE.search(cmd) and raw_force(cmd):
    sys.exit(0)

for seg in re.split(r"\|\||&&|[;|\n]", cmd):
    try:
        toks = shlex.split(seg)
    except ValueError:
        # Fail closed: unparseable and looks like a forced push.
        if raw_force(seg):
            sys.exit(0)
        continue
    for i, t in enumerate(toks):
        if t != "git" and not t.endswith("/git"):
            continue
        # Do not try to skip git global options precisely; take the first
        # "push" token after git and check everything after it.
        rest = toks[i + 1:]
        if "push" in rest and is_force(rest[rest.index("push") + 1:]):
            sys.exit(0)
sys.exit(1)
'; then
	printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force-push is blocked (hard rule: never force-push). To update a pushed branch, merge origin/main into it instead of rebasing, and ask for review before pushing."}}'
fi
exit 0
