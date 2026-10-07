# Dotfiles

Personal macOS environment: Zsh, WezTerm, Starship, Neovim and gitui.
WezTerm uses Geist Mono with Symbols Nerd Font Mono; both fonts are in Brewfile.

## Install

Requires macOS, Xcode Command Line Tools (including Git and Make), Bash and Zsh,
plus internet access for packages and editor/terminal plugins. If the Command
Line Tools are missing, run `xcode-select --install` and finish the installation
before continuing. Bootstrap installs Homebrew and mise if they are missing.

Back up existing configurations first: the link installer does not create
backups. Existing symlinks are replaced automatically; replacing ordinary
files/directories requires confirmation. Keep the repository at its installed
location because configuration links point into it.

```sh
git clone https://github.com/nashabanov/dotfiles.git ~/dotfiles
cd ~/dotfiles
make bootstrap-fresh
exec zsh
```

`make bootstrap-fresh` runs [scripts/bootstrap.sh](scripts/bootstrap.sh), which
prepares Homebrew and mise, then runs `make bootstrap` to install
[Brewfile](Brewfile) packages, create configuration links (including the global
mise configuration), and install tools from [mise/config.toml](mise/config.toml)
and [mise/conf.d/nvim.toml](mise/conf.d/nvim.toml).
If Homebrew and mise are already available in `PATH`, `make bootstrap` can also
be run directly. The new Zsh session activates mise automatically.

Open `nvim` once to install Lazy plugins; WezTerm downloads its
tabline plugin when first loading the configuration. Launch OrbStack once to
initialize Docker integration.

`make links` (or `bash scripts/symlinks.sh`) creates only the links in
[symlinks.conf](symlinks.conf).

## Tools and checks

- [Brewfile](Brewfile): applications, system tools, Zsh plugins and fonts.
- [mise/config.toml](mise/config.toml): Go 1.26, Node LTS, Python 3.13, Rust stable,
  Tree-sitter, Codex, pre-commit, search tools, formatters and linters.
  Project configurations can override runtime versions; Rust uses rustup.
  Pre-commit uses mise's `pipx:` backend with managed uv; no separate pipx
  installation is needed. This backend also works with mise versions that
  do not yet support the newer `pypi:` name.
- [mise/conf.d/nvim.toml](mise/conf.d/nvim.toml): Neovim/editor LSP dependencies.

| Command | Purpose |
| --- | --- |
| `make bootstrap-fresh` | Prepare Homebrew and mise if missing, then run bootstrap |
| `make bootstrap` | Install packages, links and tools with Homebrew and mise available |
| `make doctor` | Check commands, links, packages, Zsh integrations and shell syntax |
| `make lint` | ShellCheck, Ruff, StyLua, Selene and Zsh syntax checks |
| `make test` | Shell and Neovim regression tests |
| `make check` | Doctor, lint and tests |
| `make zsh-completions` | Regenerate Zsh completions for managed tools |
| `make tools-update` | Upgrade mise tools |
| `make brew-update` | Update/upgrade Homebrew packages and offer Brewfile cleanup |
| `make update` | Run both update targets |

Run checks from a shell with mise activated. Neovim tests need the installed
`go-context.nvim` plugin. Doctor reports `OK`, `FAIL` and `WARN`; failures return
a nonzero status. Colors follow the terminal, `NO_COLOR` and `FORCE_COLOR=1`.
Use `:checkhealth` for Neovim runtime diagnostics.

[CI](.github/workflows/ci.yml) runs `make lint test` on macOS for pushes and pull
requests, using the `go-context.nvim` revision from `nvim/lazy-lock.json`.
[Fresh-install smoke](.github/workflows/smoke.yml) runs weekly and manually on
macOS: `make bootstrap-fresh`, doctor, login/interactive Zsh and real headless
Neovim startup, waiting for Lazy to restore locked plugins first. It uses
Homebrew's `HOMEBREW_BUNDLE_CASK_SKIP` with casks read from Brewfile to omit
desktop apps and fonts; doctor respects the same exclusions. Normal bootstrap
still installs the full Brewfile when this variable is unset.

Homebrew cleanup can propose removing packages outside Brewfile and return a
nonzero status if cleanup is declined, stopping `make update`. Review its list;
`make tools-update` can be run separately. Avoid global npm/uv installations of
commands already managed by mise.

## Neovim

Space is the leader key. Main shortcuts:

| Keys | Action |
| --- | --- |
| `<leader>1` / `<leader>2` / `<leader>bc` | Previous / next / close buffer |
| `<leader>e` / `<leader>g` | File tree / Git status tree |
| `<leader>ff` / `<leader>fg` / `<leader>fz` | Find files / search text / fuzzy search |
| `gd` / `gr` / `gy` / `K` | Definition / references / type definition / hover |
| `<leader>ca` / `<leader>rn` | Code action / rename |
| `<leader>D` / `<leader>ih` | Line diagnostics / toggle inlay hints |
| `]h` / `[h` / `<leader>hs` | Next / previous / stage or unstage Git hunk |
| `<leader>hp` / `<leader>hi` / `<leader>?` | Hunk popup / inline preview / local mappings |

LSP servers are listed in [servers.lua](nvim/lua/lsp/servers.lua).
Format-on-save uses Ruff for Python, lua_ls for Lua, gopls for Go and
rust-analyzer for Rust. Formatting failures do not block saving.
`:FormatOnSaveToggle` toggles formatting for the current buffer.

## Maintain inventories

Edit [symlinks.conf](symlinks.conf) once to update the link installer, doctor and
uninstaller. Each row is `repository source|path relative to HOME|display name`.

Doctor derives commands from Brewfile and mise. For different executable names
or multiple commands, annotate the package declaration:

```toml
ripgrep = "latest" # doctor: rg
node = "lts" # doctor: node npm
```

Backend-qualified mise tools require `# doctor:`; `# doctor: -` means no CLI.
Brewfile also supports `# doctor-file:` for files relative to the Homebrew prefix
and `# doctor-app:` for app executables under `/Applications` or
`~/Applications`. See existing declarations for examples.
The inventory parser requires a real Python >=3.11 executable; it skips mise
shims to avoid triggering installations while reading inventories.

## Uninstall

```sh
bash scripts/uninstall.sh --dry-run     # Preview the removal plan
bash scripts/uninstall.sh              # Apply after confirmation
bash scripts/uninstall.sh --links-only # Remove only managed configuration links
bash scripts/uninstall.sh --purge-data # Also delete application data
```

Default cleanup removes all versions of mise tools declared here, installed
Brewfile packages/apps/fonts, managed links and Neovim/Starship caches. These
tools may also be used by other projects. `--purge-data` additionally deletes
Neovim data/state, WezTerm plugin data and cask data via `--zap`, potentially
including **OrbStack VMs and containers**. Back up needed data first.

`--yes` skips confirmation. Invalid cleanup paths are rejected; failed removal
stops later stages without rolling back completed steps. Homebrew dependency
checks remain enabled. Repository files, Homebrew, foreign configurations and
unmanaged installations are preserved.
