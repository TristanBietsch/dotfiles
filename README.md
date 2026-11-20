# dotfiles

Personal dotfiles for macOS, Arch Linux, NixOS and FreeBSD, managed with GNU Stow.

## support

| | macOS | Arch Linux | NixOS | FreeBSD |
|---|---|---|---|---|
| Packages | Homebrew, `Brewfile` | pacman + paru, `packages/arch.txt` + `packages/aur.txt` | declarative, `nix/packages.nix` | pkg, `packages/freebsd.txt` |
| Linking | stow | stow | stow (via `nix-shell` if missing) | stow |
| Commit signing | 1Password | 1Password | 1Password | ssh-agent |
| aerospace, karabiner, raycast | yes | no | no | no |
| Tested | linking only; full run with `brew bundle` **untested** | full run (Docker) | linking (container); **untested** on real NixOS | **untested**; package names checked only |
| Details | below | [docs/os/arch.md](docs/os/arch.md) | [docs/os/nixos.md](docs/os/nixos.md) | [docs/os/freebsd.md](docs/os/freebsd.md) |

## install

```sh
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Before running it:

- **Arch:** run as a normal user with `sudo`; install `git` first.
- **NixOS:** import `nix/packages.nix` into your system config and rebuild first. See [docs/os/nixos.md](docs/os/nixos.md).
- **FreeBSD:** `pkg install bash git sudo` as root first.

The script detects the platform, then:

1. Installs packages: Homebrew and `brew bundle` on macOS, `pacman` then `paru` on Arch, `pkg` on FreeBSD. NixOS is skipped.
2. Symlinks each package into `$HOME` with `stow -R --no-folding`. `aerospace` and `karabiner` are macOS only.
3. Points git at the platform's signing config (see [per-OS config](#per-os-config)).
4. macOS only: imports Raycast preferences and frees Cmd+Space from Spotlight.

Re-run it any time. It is idempotent. `NONINTERACTIVE=1 ./install.sh` answers yes to package-manager prompts.

## per-OS config

Shared files stay identical everywhere. Platform-specific settings live in small fragments:

| What | Fragments | Picked by |
|---|---|---|
| zsh | `zsh/.config/zsh/os/{darwin,linux,freebsd}.zsh` | `.zshrc`, from `$OSTYPE` |
| git signing | `git/.config/git/os/{darwin,arch,nixos,freebsd}.gitconfig` | `~/.config/git/os.gitconfig`, written by `install.sh` |

`.gitconfig` includes `~/.config/git/os.gitconfig`. That file is generated, not tracked. To set it by hand:

```sh
git config --file ~/.config/git/os.gitconfig include.path os/<darwin|arch|nixos|freebsd>.gitconfig
```

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
| `claude-<layer>/.claude/skills.d/*.tsv` | Layer skills, vendored into `claude-<layer>/.claude/skills/` (see layers) |

```sh
claude-skills sync    # vendor pinned skills, install enabled plugins, re-link settings.json
claude-skills check   # offline lint; exit 1 on any failure
claude-skills test    # headless trigger tests (Skill tool only, no MCP); exit 1 on any failure
```

To add or update a skill, edit its row in `skills.tsv`, run `claude-skills sync`, review `git diff`, then commit. For a plugin, add it to `settings.json`, then sync.

`claude plugin install` and `/plugin` replace the `settings.json` link with a plain file. `claude-skills check` flags that, and `sync` re-links it.

## layers

A layer is an optional add-on package named `<base>-<layer>`, e.g. `claude-solana/` or `zsh-solana/`. `scripts/link.sh` finds and stows layers automatically. A downstream repo (a private copy of this one) adds its own layers by adding directories, and pulls this repo with `git merge`.

| Hook point | Base file | A layer adds |
|---|---|---|
| Claude rules | `claude/.claude/CLAUDE.md` imports `~/.claude/CLAUDE.layers.md` (generated) | `claude-<layer>/.claude/CLAUDE.<layer>.md` |
| Claude skills | `claude/.claude/skills.tsv`, `triggers.tsv` | `claude-<layer>/.claude/skills.d/*.tsv`, `triggers.d/*.tsv` |
| Claude hooks | `settings.json` calls `~/.claude/hooks/layer.sh <name> [noop\|deny]` | `claude-<layer>/.claude/hooks.d/<name>.sh` |
| zsh | `.zshrc` sources `~/.zshrc.d/*.zsh` | `zsh-<layer>/.zshrc.d/*.zsh` |

Without a layer providing a hook, `layer.sh` falls back: `noop` passes, `deny` blocks the tool call.

## checks

```sh
make check   # shellcheck, JSON, tests/, no Claude state, trufflehog, public leak check
make push    # git push (pre-push runs check), then sync the downstream copy if present
```

`scripts/link.sh` sets `core.hooksPath=.githooks`: `pre-commit` blocks Claude Code state (transcripts, memory, `~/.claude.json`, MCP config) and secrets; `pre-push` runs `make check`. CI runs the same check on every push.

## not stowed

- `packages/`, `nix/` — package lists for Arch, FreeBSD and NixOS.
- `docs/` — per-OS install notes.
- `raycast/` — imported with `defaults import` on macOS, not linked.
- `theme/` — color source and generator; see `theme/README.md`.
- `voyager/` — keyboard layout exports. Versioned here, but not linked into `$HOME`.
- `zerobrew/` — separate project, tracked here.

## stack

- shell: zsh
- editor: nvim
- terminal: ghostty, tmux
- git: git, gh
- windowing/input (macOS): aerospace, karabiner, raycast
- cli: bottom, btop, fzf, lsd, w3m, yazi
- apps/state: agy, claude, codex, ncspot, obsidian, opencode, rmpc, weather
