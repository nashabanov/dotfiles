SHELL := /bin/bash
ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: bootstrap brew-install tools-install links \
        update brew-update tools-update \
        doctor check

bootstrap: brew-install links tools-install 

brew-install:
	brew bundle --file=Brewfile

tools-install:
	mise install

links:
	"$(ROOT)./install.sh"

update: brew-update tools-update

brew-update:
	brew update
	brew upgrade
	brew bundle cleanup --file="$(ROOT)Brewfile"

tools-update:
	mise upgrade

doctor:
	@echo "mise:           $$(command -v mise)"
	@echo "rg:             $$(command -v rg)"
	@echo "fd:             $$(command -v fd)"
	@echo "fzf:            $$(command -v fzf)"
	@echo "bat:            $$(command -v bat)"
	@echo "stylua:         $$(command -v stylua)"
	@echo "ruff:            $$(command -v ruff)"
	@echo "shellcheck:      $$(command -v shellcheck)"
	@echo "golangci-lint:   $$(command -v golangci-lint)"

check:
	$(MAKE) doctor
	$(MAKE) lint
	$(MAKE) test
