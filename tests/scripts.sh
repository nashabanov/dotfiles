#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_home="$(mktemp -d)"
other_home=""
trap 'rm -rf "$test_home" "$other_home"' EXIT

assert_link() {
    local target="$1" source="$2"
    [[ -L "$target" ]]
    [[ "$(readlink "$target")" == "$source" ]]
}

HOME="$test_home" bash "$ROOT/symlinks.sh" >/dev/null
assert_link "$test_home/.wezterm.lua" "$ROOT/wezterm/.wezterm.lua"
assert_link "$test_home/.config/starship.toml" "$ROOT/starship/starship.toml"
assert_link "$test_home/.config/nvim" "$ROOT/nvim"
assert_link "$test_home/.config/gitui/key_bindings.ron" "$ROOT/gitui/key_bindings.ron"
assert_link "$test_home/.zshrc" "$ROOT/zsh/.zshrc"

HOME="$test_home" bash "$ROOT/symlinks.sh" >/dev/null
rm "$test_home/.zshrc"
ln -s "$test_home/elsewhere" "$test_home/.zshrc"
printf 'y\n' | HOME="$test_home" bash "$ROOT/uninstall.sh" --links-only >/dev/null
assert_link "$test_home/.zshrc" "$test_home/elsewhere"
[[ ! -e "$test_home/.wezterm.lua" && ! -L "$test_home/.wezterm.lua" ]]

other_home="$(mktemp -d)"
printf 'existing configuration\n' > "$other_home/.zshrc"
if printf 'n\n' | HOME="$other_home" bash "$ROOT/symlinks.sh" >/dev/null 2>&1; then exit 1; fi
[[ "$(<"$other_home/.zshrc")" == "existing configuration" ]]

echo "PASS: installation is repeatable and uninstallation preserves foreign symlinks"
