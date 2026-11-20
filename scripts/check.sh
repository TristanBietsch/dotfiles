#!/usr/bin/env bash
# check.sh — repo safety and lint checks. Run by `make check` and .githooks/pre-push.
#
#   scripts/check.sh
#
#   1. shellcheck on every tracked shell script (vendored skills excluded)
#   2. tracked JSON parses
#   3. tests/*.sh pass
#   4. no Claude Code state tracked (transcripts, memory, ~/.claude.json, MCP config, ...)
#   5. secret scan: trufflehog --no-verification (prints file:line only)
#   6. public repo only: no Slack IDs; no terms from the private deny list
#   7. work/check.sh, when a downstream repo provides it
#
# Env: CI=1 skips the trufflehog step when trufflehog is not installed.
set -euo pipefail
cd "$(dirname "$0")/.."

FAILS=0
ok() { printf '  PASS  %s\n' "$*"; }
ko() { printf '  FAIL  %s\n' "$*"; FAILS=$((FAILS + 1)); }

# Claude Code state paths. Shared with .githooks/pre-commit.
STATE_RE='(^|/)\.claude/(projects|memory|state|sessions|todos|shell-snapshots|plugins|file-history|paste-cache|statsig|ide|debug|session-env)/|(^|/)(\.claude\.json(\..*)?|\.credentials\.json|history\.jsonl|terminal_title|CLAUDE\.layers\.md)$|(^|/)\.?mcp[^/]*\.json$|\.bak'

tracked() { git ls-files --cached --others --exclude-standard "$@"; }

echo "==> shellcheck"
scripts=()
while IFS= read -r f; do
	[[ -f $f ]] || continue
	# theme/build.sh has pre-existing findings (SC2207, SC2016); excluded until fixed.
	case $f in */.claude/skills/* | obsidian/* | nvim/* | zerobrew* | theme/*) continue ;; esac
	head -1 "$f" | grep -Eq '^#!.*\b(ba)?sh\b' && scripts+=("$f")
done < <(tracked)
if shellcheck "${scripts[@]}"; then ok "shellcheck (${#scripts[@]} files)"; else ko "shellcheck"; fi

echo "==> JSON"
while IFS= read -r f; do
	[[ -f $f ]] || continue
	jq empty "$f" 2>/dev/null || ko "invalid JSON: $f"
done < <(tracked -- '*.json' ':!obsidian/' ':!*/.claude/skills/')
ok "JSON parse"

echo "==> tests"
for t in tests/*.sh; do
	[[ -f $t ]] || continue
	if bash "$t"; then ok "$t"; else ko "$t"; fi
done

echo "==> Claude state"
if hits=$(tracked | grep -E "$STATE_RE"); then ko "Claude state tracked: $(tr '\n' ' ' <<<"$hits")"; else ok "no Claude state tracked"; fi

echo "==> secrets"
if command -v trufflehog >/dev/null; then
	# Regular files only: a submodule gitlink (zerobrew) would scan its whole checkout.
	# Hunter detector excluded: it matches every 40-hex git SHA (skills.tsv pins).
	out=$(tracked | while IFS= read -r f; do [[ -f $f && ! -L $f ]] && printf '%s\0' "$f"; done | xargs -0 trufflehog filesystem --no-verification --no-update --exclude-detectors=Hunter --json 2>/dev/null |
		jq -r '"\(.SourceMetadata.Data.Filesystem.file):\(.SourceMetadata.Data.Filesystem.line // "?") \(.DetectorName)"' || true)
	if [[ -n $out ]]; then ko "possible secrets (file:line detector):"; printf '        %s\n' "$out"; else ok "trufflehog: none"; fi
elif [[ -n ${CI:-} ]]; then
	ok "trufflehog not installed (CI): skipped"
else
	ko "trufflehog not installed: brew bundle --file=Brewfile"
fi

if git remote get-url origin 2>/dev/null | grep -Eq 'github\.com[:/]TristanBietsch/dotfiles(\.git)?$'; then
	echo "==> public leak check"
	if hits=$(git grep -n -I -E '\b[CDGU]0[A-Z0-9]{8,10}\b' -- . ':!obsidian/' | cut -d: -f1,2); [[ -n $hits ]]; then
		ko "Slack IDs in public repo: $(tr '\n' ' ' <<<"$hits")"
	else
		ok "no Slack IDs"
	fi
	deny=${DOTFILES_PUBLIC_DENY:-$HOME/dotfiles-work/work/public-deny.txt}
	if [[ -f $deny ]]; then
		if hits=$(git grep -n -I -i -E -f <(grep -v -e '^#' -e '^$' "$deny") -- . ':!obsidian/' | cut -d: -f1,2); [[ -n $hits ]]; then
			ko "private deny-list terms in public repo: $(tr '\n' ' ' <<<"$hits")"
		else
			ok "no deny-list terms"
		fi
	else
		ok "deny list not present here: skipped"
	fi
fi

if [[ -x work/check.sh ]]; then
	echo "==> work/check.sh"
	if work/check.sh; then ok "work/check.sh"; else ko "work/check.sh"; fi
fi

if ((FAILS)); then echo "==> check: FAIL ($FAILS)"; exit 1; fi
echo "==> check: PASS"
