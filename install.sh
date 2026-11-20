#!/usr/bin/env bash
# install — set up these dotfiles on macOS, Arch Linux, NixOS or FreeBSD.
#
#   1. Install packages with the platform's package manager:
#        macOS    Homebrew, Brewfile
#        Arch     pacman (packages/arch.txt), then paru (packages/aur.txt)
#        NixOS    nothing; import nix/packages.nix from your system config
#        FreeBSD  pkg (packages/freebsd.txt)
#   2. Symlink each package (base + layers) into $HOME: scripts/link.sh.
#   3. Point git at this platform's commit-signing config.
#   4. macOS only: Raycast preferences, Spotlight shortcuts.
#
# Safe to re-run. If stow finds a file in $HOME that conflicts with a link,
# it aborts and prints the path — move that file aside and run again.
#
# NONINTERACTIVE=1 answers yes to every package-manager prompt.

set -euo pipefail

cd "$(dirname "$0")"

detect_os() {
	case "$(uname -s)" in
	Darwin) echo darwin ;;
	FreeBSD) echo freebsd ;;
	Linux)
		# shellcheck source=/dev/null
		. /etc/os-release
		case " ${ID:-} ${ID_LIKE:-} " in
		*" nixos "*) echo nixos ;;
		*" arch "*) echo arch ;;
		*)
			echo "unsupported Linux distribution: ${ID:-unknown}" >&2
			return 1
			;;
		esac
		;;
	*)
		echo "unsupported OS: $(uname -s)" >&2
		return 1
		;;
	esac
}

# Read a package list into PKGS, skipping comments and blank lines.
read_pkgs() {
	PKGS=()
	local line
	while read -r line; do
		line=${line%%#*}
		line=${line//[[:space:]]/}
		if [ -n "$line" ]; then
			PKGS+=("$line")
		fi
	done <"$1"
}

# Run a command as root: directly, or through sudo or doas.
as_root() {
	if [ "$(id -u)" = 0 ]; then
		"$@"
	elif command -v sudo >/dev/null; then
		sudo "$@"
	else
		doas "$@"
	fi
}

install_darwin() {
	if ! command -v brew >/dev/null; then
		echo "==> Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	echo "==> Installing Brewfile packages"
	brew bundle --file=Brewfile
}

install_arch() {
	local yes=()
	[ -n "${NONINTERACTIVE:-}" ] && yes=(--noconfirm)

	echo "==> Installing pacman packages"
	read_pkgs packages/arch.txt
	as_root pacman -Syu --needed "${yes[@]}" "${PKGS[@]}"

	# makepkg refuses to run as root, so AUR packages need a normal user.
	if [ "$(id -u)" = 0 ]; then
		echo "==> Skipping AUR packages: run as a normal user to install packages/aur.txt"
		return
	fi

	if ! command -v paru >/dev/null; then
		echo "==> Installing paru (AUR helper)"
		local tmp
		tmp=$(mktemp -d)
		git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
		(cd "$tmp/paru-bin" && makepkg -si "${yes[@]}")
		rm -rf "$tmp"
	fi

	echo "==> Installing AUR packages"
	read_pkgs packages/aur.txt
	paru -S --needed "${yes[@]}" "${PKGS[@]}"
}

install_nixos() {
	echo "==> NixOS installs packages declaratively; skipping"
	echo "    Import nix/packages.nix from configuration.nix or home-manager."
	echo "    See docs/os/nixos.md."
}

install_freebsd() {
	local yes=()
	[ -n "${NONINTERACTIVE:-}" ] && yes=(-y)

	echo "==> Installing pkg packages"
	read_pkgs packages/freebsd.txt
	as_root pkg install "${yes[@]}" "${PKGS[@]}"
}

macos_settings() {
	# Raycast rewrites its plist through cfprefsd, which replaces a symlink with
	# a regular file, so import the settings instead of stowing them.
	if [ -d /Applications/Raycast.app ]; then
		echo "==> Raycast preferences"
		defaults import com.raycast.macos raycast/com.raycast.macos.plist
	fi

	# Free Cmd+Space for Raycast: turn off Spotlight's "Show Spotlight search"
	# (64, Cmd+Space) and "Show Finder search window" (65, Cmd+Opt+Space).
	echo "==> Disabling Spotlight shortcuts"
	local id mods
	for id in 64 65; do
		mods=1048576
		[ "$id" = 65 ] && mods=1572864
		defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
			"<dict><key>enabled</key><false/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>32</integer><integer>49</integer><integer>$mods</integer></array></dict></dict>"
	done
	/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
}

OS=$(detect_os)
echo "==> Platform: $OS"

# NixOS may not have stow installed system-wide; borrow it for this run.
if [ "$OS" = nixos ] && ! command -v stow >/dev/null; then
	exec nix-shell -p stow --run "$(printf '%q' "$PWD/install.sh")"
fi

"install_$OS"

echo "==> Linking configs"
./scripts/link.sh

# .gitconfig includes ~/.config/git/os.gitconfig; point it at this platform's
# signing fragment in git/.config/git/os/.
echo "==> Git signing config"
mkdir -p "$HOME/.config/git"
git config --file "$HOME/.config/git/os.gitconfig" include.path "os/$OS.gitconfig"

[ "$OS" = darwin ] && macos_settings

if command -v claude >/dev/null; then
	echo "==> Claude skills and plugins"
	"$HOME/.local/bin/claude-skills" sync
	"$HOME/.local/bin/claude-skills" check
fi

if [ "$(basename "${SHELL:-}")" != zsh ]; then
	echo "==> Login shell is ${SHELL:-unset}. Switch with: chsh -s \"\$(command -v zsh)\""
fi

echo "==> Done"
