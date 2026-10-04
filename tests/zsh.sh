#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
zsh_home="$(mktemp -d)"
trap 'rm -rf "$zsh_home"' EXIT
ln -s "$ROOT/zsh/.zshrc" "$zsh_home/.zshrc"
# The synthetic HOME has no trusted mise state; keep activation isolated.
mkdir -p "$zsh_home/.local/bin"
printf '#!/bin/sh\nexit 0\n' > "$zsh_home/.local/bin/mise"
chmod +x "$zsh_home/.local/bin/mise"

output="$(HOME="$zsh_home" ZDOTDIR="$zsh_home" zsh -dfic 'source "$HOME/.zshrc"; print -r -- "$DOTFILES_ZSH_DIR"; print -rl -- $path')"
[[ "${output%%$'\n'*}" == "$ROOT/zsh" ]]
[[ "$(printf '%s\n' "$output" | grep -Fc "$zsh_home/.local/bin")" == 1 ]]
[[ "$(printf '%s\n' "$output" | grep -Fc "$zsh_home/.o3-cli/bin")" == 1 ]]
[[ "$(printf '%s\n' "$output" | grep -Fc /opt/homebrew/bin)" -le 1 ]]

echo "PASS: Zsh resolves the linked configuration and keeps PATH entries unique"

# FZF widgets must load from PATH even without a Homebrew fzf installation.
ZDOTDIR="$zsh_home" zsh -dfic '
  autoload -Uz compinit
  compinit -u -D
  unset HOMEBREW_PREFIX
  source "$1/zsh/fzf.zsh"
  (( $+functions[fzf-file-widget] && $+functions[fzf-history-widget] && $+functions[fzf-cd-widget] ))
' -- "$ROOT"
echo "PASS: mise FZF shell widgets load independently of Homebrew"
