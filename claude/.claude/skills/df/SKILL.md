---
name: df
description: Sync the user's dotfiles repos on demand. Pulls and pushes each repo, carries public changes downstream, adopts allowlisted drift, re-links stow packages, installs missing packages and re-checks Claude skills. Use when the user types /df, or asks to sync, update or pull their dotfiles, or to install what their dotfiles are missing. Also routes a downstream commit to the public repo (/df route) and imports edits made in an export copy (/df import-org).
argument-hint: "[status | go | route <commit> | import-org | macos]"
---

# df: dotfiles sync

`/df` replaces the retired `dotsync` timer and hooks. Nothing syncs on its own any more: this skill is the only sync.

**Before anything else, read every `~/.claude/df.*.md` file.** These are machine layer files, stowed from layer packages. Their rules add to this file, and they win on conflict.

Repos:
- **Public:** `~/dotfiles`, branch `master`, remote `origin`.
- **Downstream:** `~/dotfiles-work`, if it has `work/sync.sh`. A layer file defines its rules.
- **Stowed repo:** the downstream repo if there is one, otherwise `~/dotfiles`. `$HOME` links point into it.

## Hard rules

In every mode, never:
- force-push, `git reset --hard`, `--no-verify` or `--no-gpg-sign`
- commit edits the user made by hand. A dirty repo means: list its files and ask whether to commit them or leave them out of this sync.
- run `sudo`, `curl … | sh`, `./install.sh`, `make install` or `make update`. Give the user the command instead.
- install a timer, LaunchAgent, systemd unit or cron job
- stow the `dotsync` package
- run `defaults` or a Raycast import, except in `/df macos`
- print secret values. trufflehog runs only with `--no-verification`, and reports `file:line` only.

On a GPG or 1Password signing error, ask the user to unlock 1Password, then retry. On anything this file doesn't cover, stop, report, and ask.

## Modes

| Command | Does |
| --- | --- |
| `/df status` | Step 1 only. Changes nothing. |
| `/df` | Steps 1–4, with one confirmation after Step 2 |
| `/df go` | Steps 1–4 without the confirmation. Still stops for dirty repos, conflicts and anything that needs `sudo`. |
| `/df route <commit>` | Section "route" |
| `/df import-org` | Follow the layer file. With no layer file, say it isn't available on this machine. |
| `/df macos` | Section "macos" |

## Step 1: State (read-only)

Run `bash ~/.claude/skills/df/scripts/status.sh`. It runs `git fetch` (its only network call) and prints:
- each repo's branch, dirty files, behind/ahead counts, any rebase or merge in progress, and parked `conflict/*` branches
- submodules
- drift
- missing Brewfile packages
- leftovers from the old dotsync

Also run the Step 1 checks that the layer files add.

## Step 2: Plan

Show one table, with a row per repo: repo | pull | push | notes. Under it, list:
- submodules to initialize
- packages to install
- drift to adopt or relink
- dotsync leftovers to remove
- anything blocked, with the reason

Then ask "Go?" (skip the ask in `/df go`). Anything other than a yes stops here.

## Step 3: Run

Work in this order. When a step fails for one repo, skip the rest of that repo's steps, carry on with the steps that don't depend on it, and report the failure.

1. **Public repo.** Skip it, and report why, if it's not on `master`, is mid-rebase or mid-merge, or the user said to leave its dirty files. Note `n = git stash list | wc -l` first.
    - Behind and ahead: `git -C ~/dotfiles rebase --autostash origin/master`. On a conflict, run `git rebase --abort`, then `git -C ~/dotfiles branch conflict/dotfiles/$(date +%Y%m%d-%H%M%S)`. Report the branch and skip the rest of this repo.
    - Behind only: `git -C ~/dotfiles merge --ff-only --autostash origin/master`.
    - If the stash count grew past `n`, the user's edits clashed with what came in. Tell them their edits are in `git stash list`.
    - Ahead: `git -C ~/dotfiles push origin HEAD:master`. `pre-push` runs `make check`. If it fails, show the failing lines and stop this repo.
2. **Drift.** These are the lines of `~/dotfiles/scripts/drift-allow.txt` that status reported. Each line is `<pkg>/<path>`, and the live file is `~/<path>`.
    - **Relink only** (the live file matches the repo copy): move the live file to `~/.local/state/df/drift-backup/<time>/<path>`, then run `stow -R --no-folding -d <stowed repo> -t ~ <pkg>`.
    - **Adopt** (the live file differs):
        1. Show `diff <repo copy> <live>`.
        2. Scan the live file: JSON must parse; there must be no match for `\b[CDGU]0[A-Z0-9]{8,10}\b`; no term from any deny list a layer file names; and `trufflehog filesystem <file> --no-verification --no-update --exclude-detectors=Hunter --json` must print nothing. If any check fails, don't adopt, and report it.
        3. Ask. On a yes, copy the live file into `~/dotfiles/<line>`, commit `chore(<pkg>): adopt live changes to ~/<path>`, and push.
        4. Relink once the stowed repo has that version. On the downstream repo, that means after step 3.
    - **Other replaced links** that status reported: report only. Never touch them.
3. **Downstream.** Follow the layer file. With no layer file, skip this step.
4. **Submodules** in the stowed repo: `git submodule update --init <path>`, only for paths that status showed as not initialized. A submodule moved locally (`+`) is reported, never reset.
5. **Link:** run `<stowed repo>/scripts/link.sh`. If it reports a stow conflict, show the path and leave the file alone. Then remove the old dotsync link: if `~/.local/bin/dotsync` is a link into a dotfiles repo, run `stow -D -d <that repo> -t ~ dotsync`.
6. **Packages.**
    - macOS: for each package status reported missing, check `command -v` first, because a `brew` wrapper may install outside Homebrew's Cellar. Install the rest of the formulae with one `brew install <names>`. Install casks the same way, unless the cask is a `.pkg` installer that needs an admin password. For those, give the user the exact command.
    - Arch and FreeBSD: list what's missing from `packages/*.txt` and give the install command, which needs root.
    - NixOS: report only.
    - If `brew` itself is missing, stop and tell the user. Never bootstrap it.
7. **Claude:** run `~/.local/bin/claude-skills check`. On a FAIL, run `claude-skills sync`, then check again.
8. **Old dotsync timer** (only if status reported it):
    - macOS: `launchctl bootout gui/$(id -u)/local.dotsync; rm -f ~/Library/LaunchAgents/local.dotsync.plist`
    - Linux: `systemctl --user disable --now dotsync.timer; rm -f ~/.config/systemd/user/dotsync.{service,timer}`
    - cron: show the line and have the user remove it with `crontab -e`.

## Step 4: Report

No recap and no preamble. Give:
1. A table: repo | pulled | pushed | result
2. **Installed:** packages and submodules
3. **Skipped:** each item with its reason
4. **Needs you:** the exact commands, for anything that needs `sudo`, hand edits or a conflict fix. For a parked conflict: `cd <repo> && git rebase origin/master`, resolve, run `/df`, then `git branch -D <conflict branch>`.

## route

`/df route <commit>` moves one unpushed downstream commit that changes only base files into the public repo. Follow these steps exactly.

1. Refuse when any of these is true:
    - there's no downstream repo
    - either repo is dirty
    - the commit is already pushed: `git -C <down> merge-base --is-ancestor <c> origin/master` succeeds
2. The layer paths are the lines of `<down>/work/layer-paths`, skipping comments. Build the patch: `git -C <down> diff --binary <c>^ <c> -- . ':(exclude)<path>'…` into a temp file. Refuse if the patch is empty. Also refuse if the commit touches a layer path (`git diff --name-only <c>^ <c> -- <layer paths>` isn't empty), and tell the user to split the commit first.
3. Scan the added lines (`^+`): no Slack-ID pattern, no deny-list term, and an empty result from trufflehog on the patch file. Any hit means refuse.
4. Show `git -C <down> log -1 --format='%h %s' <c>` and the full patch. Ask: "Apply exactly this patch to ~/dotfiles and push?"
5. On a yes:
    1. `git -C ~/dotfiles apply --3way <patch>`
    2. Commit with the same subject, and the body `Routed from <down repo name>@<short sha>.`
    3. Push.
    4. `git -C <down> rebase --onto <c>^ <c> master`
6. Run `/df` so the change comes back downstream.

## macos

1. Warn the user that the Raycast import overwrites their local Raycast preferences, and get a yes.
2. Run the commands in the `macos_settings` function of `<stowed repo>/install.sh`. Run each command directly. Never run `install.sh` itself.
