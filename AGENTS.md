# Instructions for working on dotfiles

Personal macOS environment: Zsh, WezTerm, Starship, Neovim, and gitui.
Make minimal changes to repository sources; user configurations are connected
through symlinks. Edit the sources rather than installed copies.

## Tool ownership

Each explicitly managed tool must have one owner responsible for installation,
version selection, updates, and removal. First inspect `Brewfile`,
`mise/config.toml`, `mise/config.d/*.toml`, and the relevant application configuration.

| Owner | Responsibility | Source of truth |
| --- | --- | --- |
| Homebrew | Applications, fonts, Zsh plugins, system and infrastructure utilities, and mise itself | `Brewfile` |
| mise | Go, Node, Python, Rust; developer CLIs, formatters, linters, and LSP servers | `mise/config.toml`, `mise/config.d/*.toml` |
| rustup through mise | Rust toolchain and its components: rustc, cargo, rustfmt, clippy | The `rust` declaration in mise |
| Lazy.nvim | Neovim plugins and their versions | `nvim/lua/core/plugins.lua`, `nvim/lua/plugins/*.lua`, `nvim/lazy-lock.json` |
| Application plugins | Application resources: Tree-sitter parsers, WezTerm tabline, and similar internal dependencies | The relevant plugin configuration |
| Project dependency manager | Libraries and local tools for a specific project | That project's manifest and lockfile |

### Selection and boundaries

- Preserve the existing owner. For example, `neovim`, `gitui`, `starship`,
  `eza`, `gh`, `lefthook`, `luacheck`, and `opencode` belong to Homebrew;
  `ripgrep`, `fd`, `fzf`, `bat`, `uv`, `ruff`, `stylua`, `shellcheck`,
  `golangci-lint`, Codex, and pre-commit belong to mise. Consult the manifests
  for the current inventory.
- Add new runtimes, developer CLIs, LSP servers, formatters, and linters to mise
  by default. Add applications, fonts, Zsh plugins, and system utilities to
  Brewfile. Explain any exception in the change description.
- A mise backend (`npm:`, `pypi:`, `go:`, `github:`, etc.) is an installation
  mechanism within mise, not a separate owner. For example, update
  `npm:@openai/codex` through mise, not through `npm install -g`.
- Do not install mise-managed commands in parallel through Homebrew,
  `npm install -g`, `pip install`, `pipx install`, `uv tool install`,
  `cargo install`, `go install`, or third-party installation scripts.
  Do not add global installations to shell startup or bootstrap scripts
  that bypass the manifests.
- `uv`/`uvx`, npm, pip, and cargo may manage project-local dependencies or run
  tools temporarily in isolated environments. Do not use them to create a
  second permanent global installation of an already managed command.
- mise installs LSP servers; Neovim configures and runs them. Do not add Mason
  or automatic installation of external CLIs from Neovim. LSP declarations
  live in `mise/config.d/nvim.toml`; the server list is in
  `nvim/lua/lsp/servers.lua`. Ruff serves as both a CLI and an LSP server;
  it does not need a separate editor installation.
- The mise declaration manages the Rust toolchain through rustup. Do not add
  an independent Homebrew Rust installation or a second rustup bootstrap.
  `rust-analyzer` already has its own mise declaration; do not install a
  competing server through another manager or as a toolchain component.
- mise owns the Tree-sitter CLI; nvim-treesitter owns parsers. Homebrew owns
  OrbStack, which provides the Docker CLI. Do not add a competing Docker
  installation without an explicit task to change ownership.
- Do not turn Homebrew transitive dependencies into explicit declarations
  merely because they were installed. A command's presence in PATH does not
  establish ownership. Check `command -v`/`type -a`, manifests, and the manager.
- Do not hide installation conflicts by reordering PATH. Preserve mise
  activation in `zsh/mise.zsh` and PATH preparation in `zsh/path.zsh`.

### Transferring ownership

When changing managers, remove the old declaration and add the new one in the
same change. Align versions, executable names, doctor annotations, documentation,
and related configurations. Describe how to verify the new installation and
remove the old one. Do not automatically remove unrelated installations you
find: other projects may use them. Only remove installations on the machine
within the scope of the requested task.

## Manifests and installation

- `bootstrap.sh` prepares Homebrew and mise, then invokes `make bootstrap`.
  Preserve the order: Brewfile → symlinks → mise tools.
- `symlinks.conf` is the single link inventory for installation, doctor, and
  removal. Each row is `repository source|path relative to HOME|display name`.
  Add new links here without duplicating inventories in scripts.
- `lib/inventory.py` reads Brewfile and mise configurations, including
  `config.d/*.toml`. Do not duplicate a tool key across mise files.
- For backend-qualified tools and tools with different executable names, add
  `# doctor: <commands>` beside the declaration. `# doctor: -` means no CLI.
  In Brewfile, use `# doctor-file:` for paths relative to the Homebrew prefix
  and `# doctor-app:` for application executables.
- Doctor and inventory reads must remain free of side effects: no installation,
  updates, or network version resolution. Inventory needs a real Python >=3.11
  executable; do not invoke a mise shim just to read manifests.
- Do not run bootstrap, package updates, or uninstall for routine change
  verification. `brew bundle cleanup` can affect packages outside Brewfile;
  uninstall removes all versions of declared mise tools, and `--purge-data`
  can delete application data, including OrbStack VMs and containers.

## Validating changes

Use Makefile targets from the repository root:

- `make lint` — ShellCheck, Ruff, and Zsh syntax checks.
- `make test` — shell and Neovim regression tests.
- `make doctor` — checks of the installed environment, packages, and links.
- `make check` — all three checks; doctor depends on the machine's state.

Run relevant tests for script, inventory, or Neovim changes. Before completing
substantial changes, run `make lint test`, as CI does. Neovim tests require an
installed `go-context.nvim` or `GO_CONTEXT_PATH` pointing to the revision from
`nvim/lazy-lock.json` (see `.github/workflows/ci.yml`). For documentation-only
changes, verify the content against sources and check the diff. Report failed
or unavailable checks.

Preserve shell-script compatibility with the macOS Bash version in use and
existing path validation and removal confirmations. Do not change plugin
lockfiles or pinned revisions unnecessarily; Tree-sitter is pinned for Neovim
0.11 compatibility. Do not commit logs, caches, secrets, or machine-specific
paths. Update README alongside configuration when user-facing behavior changes.
