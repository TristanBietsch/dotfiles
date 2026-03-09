# dotfiles

unix-style dotfiles managed with a custom stow-link installer.

## install

```sh
git clone https://github.com/TristanBietsch/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install
```

## what's inside

| package    | what                              |
|------------|-----------------------------------|
| aerospace  | tiling window manager config      |
| btop       | system monitor                    |
| claude     | claude code settings + hooks      |
| codex      | openai codex config               |
| ghostty    | terminal emulator                 |
| git        | gitconfig                         |
| karabiner  | keyboard remapping                |
| lsd        | ls replacement config             |
| ncspot     | spotify TUI                       |
| nvim       | neovim (lazy.nvim, LSP, etc.)     |
| obsidian   | vault settings + plugin prefs     |
| ranger     | file manager                      |
| tmux       | terminal multiplexer              |
| w3m        | terminal web browser              |
| weather    | weather script                    |
| zerobrew   | homebrew alternative (submodule)  |
| zsh        | shell config                      |

## commands

```sh
make install    # link configs + install packages
make link       # symlink only
make brew       # homebrew packages only
make uninstall  # remove links, restore backups
make dry-run    # preview changes
make update     # pull + reinstall
```
