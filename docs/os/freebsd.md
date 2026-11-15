# FreeBSD

## install

`install.sh` is a bash script, and FreeBSD ships without bash. Bootstrap as root first:

```sh
pkg install bash git sudo   # or doas
```

Then, as your user:

```sh
git clone <repo> ~/dotfiles
cd ~/dotfiles
./install.sh
chsh -s /usr/local/bin/zsh
```

The script:

1. Runs `pkg install` with everything in `packages/freebsd.txt`, through `sudo` or `doas`.
2. Links the shared stow packages (not `aerospace` or `karabiner`).
3. Writes `~/.config/git/os.gitconfig` to include `git/.config/git/os/freebsd.gitconfig`.

`NONINTERACTIVE=1 ./install.sh` passes `-y` to pkg.

`packages/freebsd.txt` was checked against the `FreeBSD:14:amd64` and `FreeBSD:14:aarch64` `latest` package indexes.

## Commit signing

1Password has no FreeBSD build, so `freebsd.gitconfig` leaves `gpg.ssh.program` unset and git signs with plain `ssh-keygen`. The private key has to be reachable through ssh-agent. Pick one:

- Forward your agent when you connect: `ssh -A <host>`. The key stays in 1Password on the machine you connect from.
- Load a local key: `eval "$(ssh-agent -s)"`, then `ssh-add ~/.ssh/<key>`. Its public half must match `user.signingkey` in `git/.gitconfig`.

## Not in FreeBSD packages

Install these by hand if you want them:

| Tool | Install |
|---|---|
| `pnpm` | `npm install -g pnpm` |
| `typescript` | `npm install -g typescript` |
| `marp-cli` | `npm install -g @marp-team/marp-cli` |
| `posting` | `pipx install posting` |
| `rmpc` | `cargo install --locked rmpc` |
| `obsidian-cli` (yakitrak tap) | build from source |

`mactex-no-gui` maps to `texlive-full` if needed. `aerospace`, `karabiner-elements`, `caffeine` and `shortcat` are macOS only.

`nerd-fonts` installs the whole Nerd Fonts collection, which is large.

## Configs that stay macOS-flavored

- `ghostty` config sets `macos-*` options. Ghostty ignores them off macOS.
- `codex/.codex/config.toml` points an MCP server at `/Applications/ChatGPT.app`. That server won't start here.
- No window manager or key-remapper config is included.
