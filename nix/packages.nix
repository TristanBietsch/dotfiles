# NixOS packages. Mirrors ../Brewfile; see docs/os/nixos.md.
#
# NixOS installs packages declaratively, so install.sh only links configs.
# Import this list from configuration.nix:
#
#   environment.systemPackages = import /home/<you>/dotfiles/nix/packages.nix { inherit pkgs; };
#
# or from home-manager:
#
#   home.packages = import ./dotfiles/nix/packages.nix { inherit pkgs; };
#
# claude-code is unfree: set nixpkgs.config.allowUnfree = true (or allow it
# with allowUnfreePredicate).
{ pkgs }:

with pkgs; [
  # Bootstrap.
  git
  stow
  zsh

  # Core daily tools.
  bottom
  btop
  elixir
  fd
  fzf
  gemini-cli
  gh
  go
  jq
  lazygit
  lsd
  marp-cli
  neovim
  neomutt
  pipx
  pnpm
  posting
  ripgrep
  rmpc
  rustc
  cargo
  shellcheck
  tmux
  tree-sitter
  typescript
  uv
  w3m
  yazi
  yt-dlp
  zig
  zoxide
  ffmpeg
  imagemagick
  poppler-utils
  resvg
  _7zz
  opencode
  bun

  # Clipboard for nvim and tmux.
  wl-clipboard
  xclip

  # Apps.
  ghostty
  kitty
  ncspot
  claude-code
  codex

  # Fonts.
  nerd-fonts.fira-code
  nerd-fonts.hack
  nerd-fonts.symbols-only
]
