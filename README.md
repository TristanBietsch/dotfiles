# dotfiles

Personal macOS/Linux dotfiles managed with GNU Stow and a small install script.

## install

```sh
git clone <repo>
cd dotfiles
make install
```

## commands

```sh
make install    # link configs and install packages
make dry-run    # show planned changes
make link       # link configs only
make brew       # install Homebrew packages from Brewfile
make packages   # install system packages
make update     # pull latest changes and reinstall
make uninstall  # remove links and restore backups
```

## layout

- Top-level directories are Stow packages. Their contents mirror paths under `$HOME`.
- `install.sh` drives linking, backups, and package installation.
- `Makefile` is the command entrypoint.
- `Brewfile` declares Homebrew packages.
- `voyager/` holds tracked keyboard layout exports; it is versioned, not stowed.

## stack

- shell: zsh
- editor: nvim
- terminal: ghostty, tmux
- git: git, gh
- windowing/input: aerospace, karabiner
- cli: btop, fzf, lsd, ranger, w3m
- apps/state: claude, codex, ncspot, obsidian, opencode, rmpc, weather
