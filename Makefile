.PHONY: install update

install:
	./install.sh

update:
	git pull --rebase
	./install.sh
