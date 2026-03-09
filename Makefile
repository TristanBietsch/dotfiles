.PHONY: install uninstall link brew packages update dry-run

install:
	./install.sh install

uninstall:
	./install.sh uninstall

link:
	./install.sh link

brew:
	./install.sh brew

packages:
	./install.sh packages

update:
	git pull --rebase
	git submodule update --init --recursive
	./install.sh install

dry-run:
	./install.sh install --dry-run
