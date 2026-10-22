# theme

One place for every color in these dotfiles.

- `themes/<name>/colors.env`: source of truth. The only file to edit.
- `themes/<name>/colors.md`, `colors.css`: generated reference (table, CSS vars).
- `templates/`: one per app, with `{{key}}`, `{{key.rgb}}` (`r;g;b`), `{{key.glob}}` (`a,b,c`).
- `active`: name of the theme in use.
- `build.sh`: renders the active theme into the stow packages.

Not a stow package. Apps never read this folder; they read the generated files.

## Change a color

1. Edit `themes/hackfast/colors.env`
2. Run `~/dotfiles/theme/build.sh`
3. Reload apps (below)

## New theme

1. `cp -r themes/hackfast themes/<name>`
2. Edit `themes/<name>/colors.env`
3. Run `./build.sh <name>` (writes `active`, rebuilds)

## Generated files

| app | file | reload |
|---|---|---|
| ghostty | `ghostty/.config/ghostty/colors` | `cmd+shift+,` |
| nvim | `nvim/.config/nvim/lua/core/palette.lua` | restart nvim |
| lsd | `lsd/.config/lsd/colors.yaml`, `icons.yaml` | none |
| lsd, zsh completion | `zsh/.config/zsh/ls_colors.zsh` | `exec zsh` |
| yazi | `yazi/.config/yazi/theme.toml` | restart yazi |

Do not edit generated files; `build.sh` overwrites them.

A new generated file needs linking once:
`cd ~/dotfiles && stow --no-folding --target=$HOME <pkg>` (not `make link`).
