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

## claude skills

Claude Code picks a skill on its own by matching the prompt against each skill's `description`. A skill is automatic when it is installed, enabled, and does not set `disable-model-invocation`. `claude-skills` keeps that state reproducible:

| File | Role |
|---|---|
| `claude/.claude/skills.tsv` | Third-party skills, pinned to a commit SHA and vendored into `claude/.claude/skills/` |
| `claude/.claude/settings.json` | Plugins (`enabledPlugins` + `extraKnownMarketplaces`) and hooks |
| `claude/.claude/triggers.tsv` | Prompt and expected skill, for trigger tests |
| `claude/.claude/skills/INSTALLED.md` | Security review notes per source |

```sh
claude-skills sync    # vendor pinned skills, install enabled plugins, re-link settings.json
claude-skills check   # offline lint; exit 1 on any failure
claude-skills test    # headless trigger tests (Skill tool only, no MCP); exit 1 on any failure
```

To add or update a skill, edit its row in `skills.tsv`, run `claude-skills sync`, review `git diff`, then commit. For a plugin, add it to `settings.json`, then sync.

`claude plugin install` and `/plugin` replace the `settings.json` link with a plain file. `claude-skills check` flags that, and `sync` re-links it.

## not stowed

- `voyager/` — keyboard layout exports. Versioned here, but not linked into `$HOME`.
- `zerobrew/` — separate project, tracked here.

## stack

- shell: zsh
- editor: nvim
- terminal: ghostty, tmux
- git: git, gh
- windowing/input: aerospace, karabiner
- cli: btop, fzf, lsd, w3m, yazi
- apps/state: agy, claude, codex, ncspot, obsidian, opencode, rmpc, weather
