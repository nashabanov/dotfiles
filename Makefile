SHELL := /bin/bash
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: bootstrap brew-install tools-install links \
        update brew-update tools-update \
        doctor lint test check uninstall

bootstrap:
	$(MAKE) brew-install
	$(MAKE) links
	$(MAKE) tools-install

brew-install:
	brew bundle --file="$(ROOT)Brewfile"

tools-install:
	cd "$(ROOT)" && mise install

links:
	"$(ROOT)./symlinks.sh"

update: brew-update tools-update

brew-update:
	brew update
	brew upgrade
	brew bundle cleanup --file="$(ROOT)Brewfile"

tools-update:
	cd "$(ROOT)" && mise upgrade

doctor:
	@bash "$(ROOT)doctor.sh"

lint:
	cd "$(ROOT)" && mise exec -- shellcheck *.sh lib/*.sh tests/*.sh
	cd "$(ROOT)" && mise exec -- ruff check lib/
	@for file in "$(ROOT)zsh/.zshrc" "$(ROOT)"zsh/*.zsh; do zsh -n "$$file" || exit; done

test:
	@cd "$(ROOT)" && for file in tests/*.sh; do bash "$$file" || exit; done
	@cd "$(ROOT)" && for file in nvim/tests/*.lua; do mise exec -- nvim --headless -u NONE -i NONE -l "$$file" || exit; done

check:
	$(MAKE) doctor
	$(MAKE) lint
	$(MAKE) test

uninstall:
	bash "$(ROOT)uninstall.sh" $(UNINSTALL_FLAGS)
