#!/usr/bin/env bash
# install — set up these dotfiles on macOS.
#
#   1. Install Homebrew if it isn't there.
#   2. Install everything in Brewfile (which includes stow).
#   3. Symlink each package into $HOME with stow.
#
# Safe to re-run. If stow finds a file in $HOME that conflicts with a link,
# it aborts and prints the path — move that file aside and run again.

set -euo pipefail

cd "$(dirname "$0")"

PACKAGES=(
	aerospace btop claude codex fzf gh ghostty git karabiner
	lsd ncspot nvim obsidian opencode ranger rmpc tmux w3m weather zsh
)

if ! command -v brew >/dev/null; then
	echo "==> Installing Homebrew"
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "==> Installing Brewfile packages"
brew bundle --file=Brewfile

echo "==> Linking configs"
for pkg in "${PACKAGES[@]}"; do
	stow -R --no-folding -t "$HOME" "$pkg"
done

echo "==> Done"
