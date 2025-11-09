# My Dotfiles

Personal configuration files for my development tools.

## Contents

- **WezTerm** - terminal emulator
- **Starship** - cross-shell prompt
- **Neovim** - text editor

## Структура
```
dotfiles/
├── wezterm/
│ └── .wezterm.lua
├── starship/
│ └── starship.toml
├── nvim/
│ ├── init.lua
│ ├── lua/
│ └── after/
├── install.ps1 # symlinks installation script
├── check.ps1 # symlinks check script
└── uninstall.ps1 # symlinks deletion script
```

## Requirements

- Windows 10/11
- PowerShell 5.1+
- Developer Mode enabled OR administrator privileges


## Installation

### Enable Developer Mode (first time only)

To create symlinks without administrator privileges:

1. Open `Settings` → `Privacy & Security` → `For developers`
2. Enable `Developer Mode`

### Clone repository
```powershell
git clone https://github.com/n.shabanov/dotfiles.git dotfiles
cd dotfiles
.\install.ps1
```

### Install configurations
```powershell
# run as administrator
cd C:\Users<username>\dotfiles
.\install.ps1
```
This creates symbolic links:
- `~\.wezterm.lua` → `dotfiles\wezterm\.wezterm.lua`
- `~\.config\starship.toml` → `dotfiles\starship\starship.toml`
- `~\AppData\Local\nvim` → `dotfiles\nvim`


## Usage

### Check symlink status
Verifies that all expected symlinks exist and point to the correct locations.
```powershell
.\check.ps1
```

### Remove symlinks
Deletes only the symbolic links (not your dotfiles repository). Safe to run before reinstalling.
```powershell
.\uninstall.ps1
```
This safely removes all symlinks. Repository files remain untouched.

