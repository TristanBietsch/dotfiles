# FreeBSD-only shell setup. Sourced by ~/.zshrc.
# 1Password has no FreeBSD build; keys and git signing go through ssh-agent.

# Same verb as macOS.
(( $+commands[xdg-open] )) && alias open='xdg-open'
