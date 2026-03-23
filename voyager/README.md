# Voyager Layout

This directory tracks the source export for the ZSA Voyager layout used in this dotfiles repo.

## Layouts

- `voyager-colemak/`: unpacked Oryx/QMK source files for the Colemak-DH variant
- `voyager-qwerty/`: unpacked Oryx/QMK source files for the QWERTY variant

## Artifacts

- `artifacts/`: original export archives kept for provenance

## Updating

1. Export the latest source zip from Oryx.
2. Replace the files in `voyager/voyager-colemak/` with the new `*_source` contents.
3. Move the original zip into `voyager/artifacts/`.
4. Commit the resulting diff.
