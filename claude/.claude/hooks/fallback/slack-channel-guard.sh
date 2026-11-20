#!/usr/bin/env bash
# Base default for the Slack guard, used when no layer provides one:
# read-only Slack tools pass; every other Slack tool is denied.
set -u
tool=$(jq -r '.tool_name // empty' 2>/dev/null) || tool=
case ${tool#mcp__plugin_slack_slack__} in
slack_read_* | slack_search_* | slack_list_* | slack_get_*) exit 0 ;;
esac
jq -nc --arg t "$tool" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:("no Slack guard layer installed; " + $t + " blocked (read-only Slack tools only)")}}'
