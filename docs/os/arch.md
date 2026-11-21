# Arch Linux

Also covers Arch-based distributions that set `ID_LIKE=arch` in `/etc/os-release` (EndeavourOS, CachyOS, ...).

## install

Run as a normal user with `sudo` (or `doas`), not as root: `makepkg` refuses to run as root, so the AUR step is skipped for root.

```sh
sudo pacman -S --needed git
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
chsh -s "$(command -v zsh)"
```

The script:

1. Runs `pacman -Syu --needed` with everything in `packages/arch.txt`.
2. Installs `paru` from the AUR if it isn't there, then installs `packages/aur.txt`. Read each PKGBUILD the first time paru shows it.
3. Links the shared stow packages (not `aerospace` or `karabiner`).
4. Writes `~/.config/git/os.gitconfig` to include `git/.config/git/os/arch.gitconfig`.

`NONINTERACTIVE=1 ./install.sh` passes `--noconfirm` to pacman, makepkg and paru.

## 1Password and commit signing

Commits are signed with 1Password's SSH agent, as on macOS.

1. Install the `1password` AUR package and sign in.
2. Turn on **Settings > Developer > Use the SSH agent**.
3. `zsh/.config/zsh/os/linux.zsh` sets `SSH_AUTH_SOCK` to `~/.1password/agent.sock` when the socket exists.
4. `arch.gitconfig` signs with `/opt/1Password/op-ssh-sign`.

## Brewfile gaps

| Brewfile | Arch |
|---|---|
| `obsidian-cli` (yakitrak tap) | none; build from source |
| `mactex-no-gui` | not installed; use `texlive-meta` if needed |
| `aerospace`, `karabiner-elements`, `caffeine`, `shortcat`, `keyty`, `keycastr` | macOS only; not replaced |
| `marp-cli`, `posting`, `claude-code`, `codex` | AUR (`packages/aur.txt`) |

## Configs that stay macOS-flavored

- `ghostty` config sets `macos-*` options. Ghostty ignores them on Linux.
- `codex/.codex/config.toml` points an MCP server at `/Applications/ChatGPT.app`. That server won't start on Linux.
- No Linux window manager or key-remapper config is included.
