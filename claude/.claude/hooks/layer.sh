#!/usr/bin/env bash
# layer.sh — run a hook supplied by a layer package, or a safe fallback.
#
#   bash ~/.claude/hooks/layer.sh <name> [noop|deny]
#
# Looks for, in order:
#   1. ~/.claude/hooks.d/<name>.sh        (from a claude-<layer>/ package)
#   2. ~/.claude/hooks/fallback/<name>.sh (base default)
#   3. the mode: noop prints nothing; deny blocks the tool call
#
# deny mode is fail-closed: the hook runs as a child process, and a non-zero
# exit, a watchdog kill (LAYER_HOOK_TIMEOUT, default 7s), output that isn't JSON, a missing jq or any error in
# this script blocks the call. Deny JSON is printed with printf (no jq).
set -u

name=${1:-}
mode=${2:-noop}

deny() {
	local r=${1//[\"\\]/}
	printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$r"
	echo "$r" >&2
	exit 0
}

if [[ $mode == deny ]]; then
	# Backstop: any unexpected failure exits 2, which Claude Code treats as a block.
	trap 'echo "layer.sh: internal error; call blocked." >&2; exit 2' ERR
	set -E
fi

input=$(cat)

if [[ ! $name =~ ^[a-z0-9-]+$ ]]; then
	[[ $mode == deny ]] && deny "layer.sh: bad hook name; call blocked."
	exit 0
fi

hook=
for c in "$HOME/.claude/hooks.d/$name.sh" "$HOME/.claude/hooks/fallback/$name.sh"; do
	[[ -f $c ]] && hook=$c && break
done

if [[ -z $hook ]]; then
	[[ $mode == deny ]] && deny "layer.sh: no $name hook installed; call blocked."
	exit 0
fi

if [[ $mode != deny ]]; then
	printf '%s' "$input" | bash "$hook"
	exit 0
fi

command -v jq >/dev/null || deny "layer.sh: jq missing, cannot validate $name; call blocked."
# Watchdog under the harness timeout (10s in settings.json): a hung hook would
# otherwise be killed by the harness, which lets the call through.
limit=${LAYER_HOOK_TIMEOUT:-7}
# Hook and watchdog write only to files or /dev/null, so a leftover child
# never holds this script's stdout/stderr open (the harness waits for EOF).
outf=$(mktemp)
errf=$(mktemp)
printf '%s' "$input" | bash "$hook" >"$outf" 2>"$errf" &
pid=$!
(sleep "$limit" && kill -9 "$pid") >/dev/null 2>&1 &
dog=$!
status=0
wait "$pid" 2>/dev/null || status=$?
{ kill "$dog" && wait "$dog"; } 2>/dev/null || true
out=$(<"$outf")
cat "$errf" >&2
rm -f "$outf" "$errf"
((status == 0)) || deny "layer.sh: $name exited $status (137 = timed out after ${limit}s); call blocked."
if [[ -n $out ]] && ! printf '%s' "$out" | jq -e 'type == "object"' >/dev/null 2>&1; then
	deny "layer.sh: $name printed invalid output; call blocked."
fi
printf '%s' "$out"
