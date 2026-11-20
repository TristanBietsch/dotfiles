#!/usr/bin/env bash
# Tests for claude/.claude/hooks/layer.sh and the base Slack fallback.
set -euo pipefail
cd "$(dirname "$0")/.."
LAYER=$PWD/claude/.claude/hooks/layer.sh
FALLBACK=$PWD/claude/.claude/hooks/fallback/slack-channel-guard.sh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0

decision() { jq -r '.hookSpecificOutput.permissionDecision // empty' 2>/dev/null || true; }
expect() {
	local want=$1 got=$2 label=$3
	if [[ $got == "$want" ]]; then echo "    ok    $label"; else echo "    FAIL  $label: want '$want' got '$got'"; fail=1; fi
}
run() { # run <home> <stdin> <args...>
	local h=$1 in=$2; shift 2
	printf '%s' "$in" | HOME=$h bash "$LAYER" "$@" | decision
}

empty=$tmp/empty; mkdir -p "$empty"
expect deny "$(run "$empty" '{}' slack-channel-guard deny)" "no hook + deny mode blocks"
expect "" "$(run "$empty" '{}' msg-marker)" "no hook + noop mode passes silently"
expect deny "$(run "$empty" '{}' '../evil' deny)" "bad hook name blocks"

h=$tmp/layer; mkdir -p "$h/.claude/hooks.d"
d=$h/.claude/hooks.d
printf '#!/usr/bin/env bash\njq -c "{seen:.x}"\n' >"$d/probe.sh"
got=$(printf '{"x":42}' | HOME=$h bash "$LAYER" probe deny | jq -r .seen)
expect 42 "$got" "delegates to hooks.d/<name>.sh with stdin"
printf '#!/usr/bin/env bash\nexit 1\n' >"$d/crash.sh"
expect deny "$(run "$h" '{}' crash deny)" "crashing hook blocks"
printf '#!/usr/bin/env bash\necho not-json\n' >"$d/garbage.sh"
expect deny "$(run "$h" '{}' garbage deny)" "non-JSON hook output blocks"
printf '#!/usr/bin/env bash\ncat >/dev/null\n' >"$d/silent.sh"
expect "" "$(run "$h" '{}' silent deny)" "hook exit 0 + no output passes"

printf '#!/usr/bin/env bash\nsleep 30\n' >"$d/hang.sh"
got=$(printf '{}' | HOME=$h LAYER_HOOK_TIMEOUT=1 bash "$LAYER" hang deny | decision)
expect deny "$got" "hung hook killed by watchdog, blocks"

nojq=$tmp/nojq; mkdir -p "$nojq"
ln -s "$(command -v cat)" "$nojq/cat"
got=$(printf '{}' | HOME=$h PATH=$nojq /bin/bash "$LAYER" silent deny)
expect deny "$(printf '%s' "$got" | decision)" "missing jq blocks"

f=$tmp/fb; mkdir -p "$f/.claude/hooks/fallback"
cp "$FALLBACK" "$f/.claude/hooks/fallback/"
expect "" "$(run "$f" '{"tool_name":"mcp__plugin_slack_slack__slack_read_thread"}' slack-channel-guard deny)" "fallback: Slack read passes"
expect deny "$(run "$f" '{"tool_name":"mcp__plugin_slack_slack__slack_create_canvas"}' slack-channel-guard deny)" "fallback: Slack canvas write blocked"
expect deny "$(run "$f" '{"tool_name":"mcp__plugin_slack_slack__slack_send_message"}' slack-channel-guard deny)" "fallback: Slack send blocked"

exit "$fail"
