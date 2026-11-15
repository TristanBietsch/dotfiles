# Linux-only shell setup (Arch, NixOS). Sourced by ~/.zshrc.

# 1Password SSH agent: enable it in 1Password > Settings > Developer.
[ -S "$HOME/.1password/agent.sock" ] && export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# Same verb as macOS.
(( $+commands[xdg-open] )) && alias open='xdg-open'
