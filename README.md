# My Dotfiles

Personal development environment for macOS, including WezTerm, Starship, Neovim, gitui, and Zsh.

## Contents

- **WezTerm**: terminal configuration with a tabline, pane shortcuts, and a translucent background.
- **Starship**: shell prompt configuration.
- **Neovim**: Lazy-managed plugins, completion, LSP support, file navigation, and Git integration.
- **gitui**: custom key bindings.
- **Zsh**: history, completion, aliases, optional plugins, and Starship initialization.
- **Brewfile**: Homebrew packages for the development environment.

## Structure

```text
dotfiles/
├── Brewfile
├── gitui/
│   └── key_bindings.ron
├── nvim/
│   ├── init.lua
│   ├── lazy-lock.json
│   ├── lua/
│   │   ├── core/
│   │   ├── lsp/
│   │   └── plugins/
│   └── tests/
│       └── format.lua
├── starship/
│   └── starship.toml
├── wezterm/
│   └── .wezterm.lua
├── zsh/
│   ├── .zshrc
│   ├── aliases.zsh
│   ├── completion.zsh
│   ├── env.zsh
│   ├── fzf.zsh
│   ├── options.zsh
│   ├── path.zsh
│   └── plugins.zsh
├── install.sh
└── uninstall.sh
```

## Requirements

- macOS with Git, Homebrew, Bash, and Zsh.
- Internet access for installing packages and downloading editor and terminal plugins.
- Clone the repository into any directory.

The Zsh configuration derives its own location and detects the Homebrew prefix, supporting both Apple Silicon and Intel installations.

## Installation

### Clone and install packages

```sh
git clone https://github.com/nashabanov/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle --file=Brewfile
```

The Brewfile includes:

- Git, uv, Go, Node.js (including npm for Mason-managed language servers), and Python 3.13.
- Neovim, gitui, WezTerm, and Starship.
- eza, fzf, ripgrep, and bat.
- fzf-tab, zsh-completions, zsh-autosuggestions, and zsh-syntax-highlighting.
- Geist Mono and Symbols Nerd Font, matching the WezTerm configuration.

The `ls` alias requires `eza`. The other shell integrations load when their commands or files are available. Ripgrep also supports Neovim's Telescope text search.

WezTerm selects **Geist Mono** with **Symbols Nerd Font Mono** as a fallback. Both are installed by the Brewfile.

### Link configurations

The intended script entry point is:

```sh
bash install.sh
```

The installer replaces existing symlinks automatically. For an existing regular file or directory, it asks before deleting and replacing it; it does not create backups. It continues with the remaining links if one target is skipped or fails, then returns a nonzero status.

```sh
mkdir -p ~/.config/gitui
ln -s ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
ln -s ~/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/gitui/key_bindings.ron ~/.config/gitui/key_bindings.ron
ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
```

If a target already exists, inspect it before replacing it. The expected links are:

| Installed path | Repository source |
| --- | --- |
| `~/.wezterm.lua` | `wezterm/.wezterm.lua` |
| `~/.config/starship.toml` | `starship/starship.toml` |
| `~/.config/nvim` | `nvim/` |
| `~/.config/gitui/key_bindings.ron` | `gitui/key_bindings.ron` |
| `~/.zshrc` | `zsh/.zshrc` |

Keep the repository at this location: edits to linked files take effect directly.

### Start using the configuration

Open a new Zsh session to load the shell configuration. Run `nvim` to bootstrap Lazy and the configured plugins. WezTerm downloads its tabline plugin when loading its configuration.

## Neovim key mappings

Both leader keys are Space and are set in `nvim/init.lua` before plugins load.
General editor mappings live in `lua/core/mappings.lua`, buffer-local LSP
mappings in `lua/lsp/attach.lua`, and plugin mappings alongside their settings
in `lua/plugins/`. Every plugin module returns a Lazy specification; setup runs
through its `opts` or `config` when Lazy loads the plugin. `lua/core/plugins.lua`
registers these specifications, while `lua/core/ui.lua` owns global transparency
and diagnostic defaults. Neo-tree highlights and window settings remain in its
plugin module.

| Keys (normal mode) | Action |
| --- | --- |
| `<leader>1` / `<leader>2` | Previous / next buffer |
| `<leader>bc` | Close the current buffer (unsaved changes require saving first) |
| `<leader>e` / `<leader>g` | Focus the file tree / Git status tree |
| `<leader>ff` | Find files |
| `<leader>fg` / `<leader>fz` | Search text / fuzzy search text |
| `<leader>fc` | Search the word under the cursor |
| `gd` / `gr` / `gy` | Definition / references / type definition (LSP) |
| `gi` / `go` | Incoming / outgoing calls (LSP) |
| `K` | Hover documentation (LSP) |
| `<leader>ca` / `<leader>rn` | Code action / rename symbol (LSP) |
| `<leader>D` / `<leader>ih` | Line diagnostics / toggle buffer inlay hints (LSP) |
| `]h` / `[h` | Next / previous Git hunk |
| `<leader>hs` | Stage/unstage the Git hunk under the cursor |
| `<leader>hp` / `<leader>hi` | Preview the current Git hunk in a popup / inline |
| `<leader>?` | Show buffer-local mappings with WhichKey |

File search uses `<leader>f` prefixes so the built-in `f{char}` motion remains
available. Cinnamon owns the smooth navigation mappings (`n`, `N`, `zz`, `zt`,
`zb`, `gg`, and `G`). Completion and dashboard shortcuts stay in their respective
plugin configurations.

Gitsigns uses `nav_hunk` for navigation and `stage_hunk` for staging and unstaging.
On a staged hunk with no unstaged changes at the cursor, `<leader>hs` unstages it;
when unstaged changes are present there, it stages those changes first. The old
`<leader>hu` (undo the last staging action) has been removed. `<leader>hi` opens
an inline preview of the current hunk; it replaces the old `<leader>td` shortcut
for showing deleted lines throughout the buffer.

## Neovim format on save

Saving a regular, writable buffer formats it through one attached LSP server
that supports document formatting. Python uses Ruff, Lua uses lua_ls, Go uses
gopls, and Rust uses rust-analyzer. If the preferred server is unavailable,
formatting is skipped. Other file types use the first capable server by name
(then client ID), so attachment order does not change the choice.

Formatting completes before the file is written, with a 1,000 ms request timeout.
A timeout or formatter error reports a warning and allows saving to continue.
Buffers without a matching formatter are skipped silently.

Run `:FormatOnSaveToggle` to disable or re-enable automatic formatting for the
current buffer. This does not affect other buffers and resets when the buffer is
deleted. For configuration or project hooks, set `vim.b.autoformat = false`.

Run the formatting regression checks from the repository root:

```sh
nvim --headless -u NONE -i NONE -l nvim/tests/format.lua
```

The checks use temporary files and simulated LSP clients, including Neovim's
synchronous request timeout and cancellation, without installing plugins.

To validate completion, Gitsigns, and Treesitter configuration without
installing plugins:

```sh
nvim --headless -u NONE -i NONE -l nvim/tests/plugins.lua
```

## Verify links

Run the following in Zsh or Bash and compare the destinations with the table above:

```sh
for target in ~/.wezterm.lua ~/.config/starship.toml ~/.config/nvim ~/.config/gitui/key_bindings.ron ~/.zshrc; do
  if [ -L "$target" ]; then
    printf '%s -> %s\n' "$target" "$(readlink "$target")"
  else
    printf 'Missing symlink: %s\n' "$target"
  fi
done
```

## Uninstallation

```sh
cd ~/dotfiles
bash uninstall.sh
```

The script asks for confirmation and removes only symlinks whose destinations match this repository. It preserves regular files, directories, foreign symlinks, and broken symlinks that do not point to a managed source.

To remove the links manually, including broken links, while checking that they point to this repository:

```sh
for target in ~/.wezterm.lua ~/.config/starship.toml ~/.config/nvim ~/.config/gitui/key_bindings.ron ~/.zshrc; do
  if [ -L "$target" ]; then
    case "$(readlink "$target")" in
      "$HOME/dotfiles/"*) rm "$target" ;;
    esac
  fi
done
```

Repository files and installed packages remain in place. Restore any previous configurations from your backups.
