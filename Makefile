.PHONY: bootstrap tools-update check doctor

bootstrap:
	mise install

tools-update:
	mise upgrade

check:
	$(MAKE) lint
	$(MAKE) test

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
