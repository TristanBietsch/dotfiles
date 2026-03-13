# Dwarf Fortress Save Repo Workflow

This repo keeps Dwarf Fortress config under dotfiles and puts save data in a separate Git repo that can be stowed into `~/Library/Application Support/Dwarf Fortress/data/save`.

## Repos

- Dotfiles repo: `dwarf-fortress/` package for `data/init`
- Save repo: `git@github.com:TristanBietsch/dwarf-fortress.git`

## Save repo layout

The target save repository is expected to look like this:

```text
.
├── df-saves/
│   └── Library/Application Support/Dwarf Fortress/data/save/
├── config/init/
├── docs/stow.md
├── meta/manifest.txt
└── .gitignore
```

`df-saves/` is the actual stow package. `config/init/` is copied in as a reference snapshot so the save repo carries enough context to restore on another machine.

## First-time setup

1. Clone the save repo locally, or let the sync script clone it.
2. Run:

```sh
./scripts/df-save-sync --repo-dir ~/src/dwarf-fortress --stow
```

3. Verify the live save directory:

```sh
find "$HOME/Library/Application Support/Dwarf Fortress/data/save" -maxdepth 1 -type l -o -type d
```

4. Commit and push the save repo if the script did not do that for you.

## Ongoing usage

After playing:

```sh
df-save
```

To sync and publish in one step:

```sh
./scripts/df-save-sync --repo-dir ~/src/dwarf-fortress --push
```

To test without making changes:

```sh
df-save --dry-run
```

To restore on another machine:

```sh
./scripts/df-save-restore --repo-dir ~/src/dwarf-fortress
stow --target="$HOME" --dir="$HOME/src/dwarf-fortress" df-saves
```

## Notes

- The sync script mirrors the entire live `data/save/` tree into the save repo.
- `df-save` is the daily command. It syncs, stows, commits, and pushes with a message like `save game 2026-03-13 16:05:00`.
- The script also writes `docs/stow.md` and `meta/manifest.txt` inside the save repo so the workflow is documented with the data.
- `install.sh` is intentionally not involved. Save stowing is manual and repo-specific.
