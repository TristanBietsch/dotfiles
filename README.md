# dotfiles

Personal macOS dotfiles, managed with GNU Stow.

## install

```sh
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script does three things:

1. Installs Homebrew if it isn't there.
2. Runs `brew bundle` — that installs Stow and everything else in `Brewfile`.
3. Symlinks each package into `$HOME` with `stow -R --no-folding`.

Re-run it any time. It is idempotent.

## packages

Each top-level directory is a Stow package. Its contents mirror paths under `$HOME`:

```
nvim/.config/nvim/init.lua   ->   ~/.config/nvim/init.lua
```

## manual stow

To link, preview, or remove one package by hand:

```sh
stow -R --no-folding -t ~ <pkg>   # link or re-link
stow -n  --no-folding -t ~ <pkg>  # preview (dry run)
stow -D  -t ~ <pkg>               # unlink
```

`--no-folding` is required. It tells Stow to symlink files one at a time instead of folding whole directories, so a config that shares a directory with unmanaged files won't get clobbered.

## not stowed

- `voyager/` — keyboard layout exports. Versioned here, but not linked into `$HOME`.
- `zerobrew/` — separate project, tracked here.

## stack

- shell: zsh
- editor: nvim
- terminal: ghostty, tmux
- git: git, gh
- windowing/input: aerospace, karabiner
- cli: btop, fzf, lsd, ranger, w3m
- apps/state: claude, codex, ncspot, obsidian, opencode, rmpc, weather
