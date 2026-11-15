# TODO

- customize rmpc
- theme: wire remaining apps to theme/ (hackfast). See theme/README.md
  - tmux: generate .tmux-theme.conf, `source-file` it from .tmux.conf
  - fzf: generate .fzfrc with a `--color=` line
  - btop: generate btop/.config/btop/themes/hackfast.theme, set `color_theme = "hackfast"`
  - kitty: generate theme.conf, `include theme.conf` in kitty.conf
- multi-OS install: verify untested paths
  - FreeBSD: run `./install.sh` on a real machine or VM
  - macOS: full `./install.sh`, including `brew bundle`
  - NixOS: `nixos-rebuild` with `nix/packages.nix`, then `./install.sh`, on real NixOS
