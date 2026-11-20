.PHONY: install update link check push

install:
	./install.sh

update:
	git pull --rebase
	./install.sh

# Stow base + layer packages; regenerate ~/.claude/CLAUDE.layers.md.
link:
	./scripts/link.sh

check:
	./scripts/check.sh

# Push (pre-push runs check), then carry the change downstream when a
# downstream checkout exists.
push:
	git push
	@if [ "$(CURDIR)" != "$$HOME/dotfiles-work" ] && [ -f "$$HOME/dotfiles-work/work/work.mk" ]; then \
		$(MAKE) -C "$$HOME/dotfiles-work" sync; \
	fi

# Downstream repos add targets here.
-include work/work.mk
