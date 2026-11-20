# NixOS

NixOS installs packages declaratively, so `install.sh` only links configs. Packages come from `nix/packages.nix`, which you import into your own system or home-manager config.

## install

1. Add the package list and shell to `configuration.nix`:

   ```nix
   { pkgs, ... }:
   {
     nixpkgs.config.allowUnfree = true; # claude-code is unfree

     environment.systemPackages = import /home/<you>/dotfiles/nix/packages.nix { inherit pkgs; };

     # Fonts in systemPackages are not registered with fontconfig.
     fonts.packages = with pkgs; [
       nerd-fonts.fira-code
       nerd-fonts.hack
       nerd-fonts.symbols-only
     ];

     programs.zsh.enable = true;
     users.users.<you>.shell = pkgs.zsh;
   }
   ```

   With home-manager, use `home.packages = import ./dotfiles/nix/packages.nix { inherit pkgs; };` and `fonts.fontconfig.enable = true;` instead.

2. Rebuild, then link the configs:

   ```sh
   sudo nixos-rebuild switch
   git clone <repo> ~/dotfiles
   cd ~/dotfiles
   ./install.sh
   ```

If `stow` isn't installed yet, `install.sh` re-runs itself inside `nix-shell -p stow`.

The script links the shared stow packages (not `aerospace` or `karabiner`) and writes `~/.config/git/os.gitconfig` to include `git/.config/git/os/nixos.gitconfig`.

## 1Password and commit signing

```nix
programs._1password.enable = true;
programs._1password-gui = {
  enable = true;
  polkitPolicyOwners = [ "<you>" ];
};
```

1. Sign in and turn on **Settings > Developer > Use the SSH agent**.
2. `zsh/.config/zsh/os/linux.zsh` sets `SSH_AUTH_SOCK` to `~/.1password/agent.sock` when the socket exists.
3. `nixos.gitconfig` signs with `op-ssh-sign` from `PATH`, which `_1password-gui` provides.

## Brewfile gaps

| Brewfile | nixpkgs |
|---|---|
| `obsidian-cli` (yakitrak tap) | none; build from source |
| `mactex-no-gui` | not included; use `texliveFull` if needed |
| `rust` | `rustc` + `cargo` |
| `sevenzip` | `_7zz` |
| `aerospace`, `karabiner-elements`, `caffeine`, `shortcat`, `keyty` | macOS only; not replaced |

`nix/packages.nix` was checked by evaluating it against `nixos-unstable`.

## Configs that stay macOS-flavored

- `ghostty` config sets `macos-*` options. Ghostty ignores them on Linux.
- `codex/.codex/config.toml` points an MCP server at `/Applications/ChatGPT.app`. That server won't start on Linux.
- No window manager or key-remapper config is included.
