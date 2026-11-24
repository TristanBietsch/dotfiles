#!/usr/bin/env bash
# status.sh — read-only dotfiles state for /df. The only network call is git fetch.
#
#   bash ~/.claude/skills/df/scripts/status.sh
#
# Env: DF_PUBLIC (~/dotfiles) DF_DOWNSTREAM (~/dotfiles-work)
set -uo pipefail

PUBLIC=${DF_PUBLIC:-$HOME/dotfiles}
DOWN=${DF_DOWNSTREAM:-$HOME/dotfiles-work}
[[ -d $DOWN/.git && -f $DOWN/work/sync.sh ]] || DOWN=
STOWED=${DOWN:-$PUBLIC}

g() { git -C "$1" "${@:2}"; }
busy() { [[ -d $1/.git/rebase-merge || -d $1/.git/rebase-apply || -f $1/.git/MERGE_HEAD ]]; }

repo() {
	local r=$1 name br behind ahead
	name=$(basename "$r")
	if [[ ! -d $r/.git ]]; then
		echo "$name: missing ($r)"
		return
	fi
	g "$r" fetch -q origin 2>/dev/null || echo "$name: fetch origin failed"
	br=$(g "$r" symbolic-ref --short HEAD 2>/dev/null || echo DETACHED)
	read -r behind ahead < <(g "$r" rev-list --left-right --count origin/master...HEAD 2>/dev/null || echo "? ?")
	printf '%s: branch=%s behind=%s ahead=%s dirty=%s%s\n' "$name" "$br" "$behind" "$ahead" \
		"$(g "$r" status --porcelain | wc -l | tr -d ' ')" "$(busy "$r" && echo ' BUSY(rebase/merge in progress)')"
	g "$r" status --porcelain | head -20 | sed 's/^/  dirty: /'
	g "$r" branch --list 'conflict/*' --format='  parked: %(refname:short)'
	g "$r" submodule status 2>/dev/null |
		awk '/^-/ { print "  submodule not initialized: " $2 } /^\+/ { print "  submodule moved locally (leave alone): " $2 }'
	if [[ $r == "$DOWN" ]] && g "$r" remote get-url upstream >/dev/null 2>&1; then
		g "$r" fetch -q upstream 2>/dev/null || echo "  fetch upstream failed"
		echo "  upstream commits not merged: $(g "$r" rev-list --count HEAD..upstream/master 2>/dev/null || echo '?')"
	fi
}

echo "==> repos (stowed from $(basename "$STOWED"))"
repo "$PUBLIC"
[[ -n $DOWN ]] && repo "$DOWN"

echo "==> drift"
allow=$PUBLIC/scripts/drift-allow.txt
listed=""
if [[ -f $allow ]]; then
	while IFS= read -r line; do
		[[ -z $line || $line == \#* ]] && continue
		listed="$listed $line"
		live=$HOME/${line#*/}
		[[ -f $live && ! -L $live ]] || continue
		if cmp -s "$live" "$STOWED/$line"; then
			echo "  relink only: ~/${line#*/}"
		else
			echo "  adopt? ~/${line#*/} differs from $(basename "$STOWED")/$line"
		fi
	done <"$allow"
fi
while IFS= read -r f; do
	live=$HOME/${f#*/}
	[[ -f $live && ! -L $live ]] || continue
	case $(cd "$(dirname "$live")" && pwd -P) in "$STOWED"/*) continue ;; esac
	[[ " $listed " == *" $f "* ]] && continue
	grep -qxF "$f" "$STOWED/scripts/per-machine.txt" 2>/dev/null && continue
	echo "  replaced link, not allowlisted (report only): ~/${f#*/}"
done < <(g "$STOWED" ls-files -- 'claude*' 'agy' 'git' 'zsh*' 'ghostty' 'nvim*' 'tmux' 'yazi' 'lsd' 'btop' \
	'bottom' 'codex' 'opencode' 'fzf' 'gh' 'kitty' 'rmpc' 'ncspot' 'weather' 2>/dev/null)

echo "==> packages"
if [[ $(uname -s) == Darwin ]]; then
	if command -v brew >/dev/null; then
		# brew bundle prints the missing list on stderr.
		HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$STOWED/Brewfile" --verbose --no-upgrade 2>&1 |
			sed -E -n 's/^→ (Cask|Formula) (.*) needs to be installed\./\1 \2/p' |
			while read -r kind name; do
				bin=${name##*/}
				if [[ $kind == Formula ]] && p=$(command -v "$bin"); then
					echo "  missing: $kind $name (but $bin is on PATH: $p)"
				else
					echo "  missing: $kind $name"
				fi
			done
	else
		echo "  brew not found"
	fi
else
	echo "  not macOS: compare $(basename "$STOWED")/packages/*.txt with installed packages"
fi

echo "==> old dotsync"
[[ -e $HOME/.local/bin/dotsync || -L $HOME/.local/bin/dotsync ]] && echo "  link present: ~/.local/bin/dotsync"
[[ -f $HOME/Library/LaunchAgents/local.dotsync.plist ]] && echo "  launchd timer present: local.dotsync"
if command -v systemctl >/dev/null && systemctl --user is-enabled dotsync.timer >/dev/null 2>&1; then
	echo "  systemd timer enabled: dotsync.timer"
fi
crontab -l 2>/dev/null | grep -q 'dotsync run' && echo "  crontab line runs dotsync"
echo "==> done"
