#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT
ln -s "$ROOT/zsh/.zshrc" "$home/.zshrc"

output="$(HOME="$home" ZDOTDIR="$home" zsh -dfc 'source "$HOME/.zshrc"; print -r -- "$DOTFILES_ZSH_DIR"; print -rl -- $path')"
[[ "${output%%$'\n'*}" == "$ROOT/zsh" ]]
[[ "$(printf '%s\n' "$output" | grep -Fc "$home/.local/bin")" == 1 ]]
[[ "$(printf '%s\n' "$output" | grep -Fc "$home/.o3-cli/bin")" == 1 ]]
[[ "$(printf '%s\n' "$output" | grep -Fc /opt/homebrew/bin)" -le 1 ]]

echo "PASS: Zsh resolves the linked configuration and keeps PATH entries unique"
