SHELL := /bin/bash
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: bootstrap bootstrap-fresh brew-install \
		tools-install links update \
        brew-update tools-update doctor \
        lint test check uninstall \
		zsh-completions

bootstrap:
	bash "$(ROOT)scripts/install.sh" $(BOOTSTRAP_FLAGS)

bootstrap-fresh:
	bash "$(ROOT)scripts/bootstrap.sh" $(BOOTSTRAP_FLAGS)

brew-install:
	bash "$(ROOT)scripts/brew.sh"

tools-install:
	cd "$(ROOT)" && mise install
	$(MAKE) zsh-completions

links:
	"$(ROOT)scripts/symlinks.sh"

update: brew-update tools-update

brew-update:
	brew update
	brew upgrade
	brew bundle cleanup --file="$(ROOT)Brewfile"

tools-update:
	cd "$(ROOT)" && mise upgrade
	$(MAKE) zsh-completions

doctor:
	@bash "$(ROOT)scripts/doctor.sh"

lint:
	cd "$(ROOT)" && mise exec -- shellcheck scripts/*.sh lib/*.sh tests/*.sh
	cd "$(ROOT)" && mise exec -- ruff check lib/
	cd "$(ROOT)" && mise exec -- stylua --check nvim
	cd "$(ROOT)" && mise exec -- selene nvim
	@for file in "$(ROOT)zsh/.zshrc" "$(ROOT)"zsh/*.zsh; do zsh -n "$$file" || exit; done

test:
	@cd "$(ROOT)" && for file in tests/*.sh; do printf 'RUN: %s\n' "$$file"; bash "$$file" || exit; done
	@cd "$(ROOT)" && for file in nvim/tests/*.lua; do printf 'RUN: %s\n' "$$file"; mise exec -- nvim --headless -u NONE -i NONE -l "$$file" || exit; done

zsh-completions:
	cd "$(ROOT)" && mise run zsh-completions-sync

check:
	$(MAKE) doctor
	$(MAKE) lint
	$(MAKE) test

uninstall:
	bash "$(ROOT)scripts/uninstall.sh" $(UNINSTALL_FLAGS)
