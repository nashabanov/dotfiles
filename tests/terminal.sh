#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
export HOME="$fixture/home" XDG_STATE_HOME="$fixture/state"
unset DOTFILES_TERMINAL HOMEBREW_BUNDLE_CASK_SKIP
mkdir -p "$HOME" "$fixture/bin"
# shellcheck source=lib/terminal.sh
source "$ROOT/lib/terminal.sh"
terminal_load
[[ "$terminal" == ghostty && ! -e "$XDG_STATE_HOME" ]]
terminal_choose </dev/null >/dev/null
[[ "$(cat "$terminal_state")" == ghostty ]]
for choice in ghostty wezterm both none; do
    unset DOTFILES_TERMINAL HOMEBREW_BUNDLE_CASK_SKIP
    terminal_choose --terminal "$choice" >/dev/null
    unset DOTFILES_TERMINAL
    terminal_load
    [[ "$terminal" == "$choice" ]]
    terminal_skip_casks
    for app in ghostty wezterm; do
        if [[ "$choice" == both || "$choice" == "$app" ]]; then
            terminal_link_enabled "$app/config"
            [[ " ${HOMEBREW_BUNDLE_CASK_SKIP:-} " != *" $app "* ]]
        else
            if terminal_link_enabled "$app/config"; then exit 1; fi
            [[ " $HOMEBREW_BUNDLE_CASK_SKIP " == *" $app "* ]]
        fi
    done
    HOME="$HOME" bash "$ROOT/scripts/symlinks.sh" >/dev/null
    output="$(bash "$ROOT/scripts/doctor.sh" 2>&1)" || :
    if [[ "$choice" == none ]]; then
        [[ "$output" != *WezTerm.app* && "$output" != *Ghostty.app* ]]
        [[ "$output" != *"$HOME/.wezterm.lua"* && "$output" != *"$HOME/.config/ghostty/config.ghostty"* ]]
    fi
done
# Switching choices preserves previously created links.
[[ -L "$HOME/.wezterm.lua" && -L "$HOME/.config/ghostty/config.ghostty" ]]
for args in '--terminal invalid' '--terminal' '--unknown'; do
    # Intentional splitting supplies separate CLI arguments.
    # shellcheck disable=SC2086
    if terminal_choose $args >/dev/null 2>&1; then exit 1; fi
    [[ "$(cat "$terminal_state")" == none ]]
done
unset DOTFILES_TERMINAL
printf 'invalid\n' > "$terminal_state"
if terminal_load 2>/dev/null; then exit 1; fi
terminal_choose --terminal ghostty >/dev/null
# Menu retries invalid answers, supports names/numbers, and accepts the default.
for pair in '1 ghostty' '2 wezterm' '3 both' '4 none' 'ghostty ghostty'; do
    read -r answer expected <<< "$pair"
    result="$(printf 'bad\n%s\n' "$answer" | { terminal_menu >/dev/null; echo "$terminal"; })"
    [[ "$result" == "$expected" ]]
done
[[ "$(printf '\n' | { terminal_menu >/dev/null; echo "$terminal"; })" == ghostty ]]
if terminal_menu </dev/null >/dev/null; then exit 1; fi
# Exercise real Makefile wiring with package managers replaced by mocks.
cat > "$fixture/bin/brew" <<'MOCK'
#!/bin/bash
printf '%s|%s\n' "$*" "${HOMEBREW_BUNDLE_CASK_SKIP:-}" >> "$TERMINAL_LOG"
MOCK
cat > "$fixture/bin/mise" <<'MOCK'
#!/bin/bash
exit 0
MOCK
chmod +x "$fixture/bin/brew" "$fixture/bin/mise"
export TERMINAL_LOG="$fixture/log"
PATH="$fixture/bin:$PATH" make -s -C "$ROOT" bootstrap BOOTSTRAP_FLAGS='--terminal wezterm' >/dev/null
[[ "$(cat "$terminal_state")" == wezterm ]]
[[ "$(cat "$TERMINAL_LOG")" == *'|ghostty' ]]
: > "$TERMINAL_LOG"
HOMEBREW_BUNDLE_CASK_SKIP=orbstack PATH="$fixture/bin:$PATH" make -s -C "$ROOT" brew-install >/dev/null
[[ "$(cat "$TERMINAL_LOG")" == *'|orbstack ghostty' ]]
echo 'PASS: terminal defaults, saved choice, menu, validation, links, doctor and bootstrap'
