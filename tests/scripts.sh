#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home="$(mktemp -d)"
other_home=""
trap 'rm -rf "$home" "$other_home"' EXIT

assert_link() {
    local target="$1" source="$2"
    [[ -L "$target" ]]
    [[ "$(readlink "$target")" == "$source" ]]
}

HOME="$home" bash "$ROOT/install.sh" >/dev/null
assert_link "$home/.wezterm.lua" "$ROOT/wezterm/.wezterm.lua"
assert_link "$home/.config/starship.toml" "$ROOT/starship/starship.toml"
assert_link "$home/.config/nvim" "$ROOT/nvim"
assert_link "$home/.config/gitui/key_bindings.ron" "$ROOT/gitui/key_bindings.ron"
assert_link "$home/.zshrc" "$ROOT/zsh/.zshrc"

HOME="$home" bash "$ROOT/install.sh" >/dev/null
rm "$home/.zshrc"
ln -s "$home/elsewhere" "$home/.zshrc"
printf 'y\n' | HOME="$home" bash "$ROOT/uninstall.sh" >/dev/null
assert_link "$home/.zshrc" "$home/elsewhere"
[[ ! -e "$home/.wezterm.lua" && ! -L "$home/.wezterm.lua" ]]

other_home="$(mktemp -d)"
printf 'existing configuration\n' > "$other_home/.zshrc"
if printf 'n\n' | HOME="$other_home" bash "$ROOT/install.sh" >/dev/null 2>&1; then exit 1; fi
[[ "$(<"$other_home/.zshrc")" == "existing configuration" ]]

echo "PASS: installation is repeatable and uninstallation preserves foreign symlinks"
