#!/usr/bin/env bash
# Shared terminal selection; state is plain data, never sourced as shell code.
terminal_load() {
    terminal_state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/terminal"
    terminal="${DOTFILES_TERMINAL:-}"
    if [[ -z "$terminal" && -f "$terminal_state" ]]; then
        terminal="$(cat "$terminal_state")" || return
    fi
    terminal="${terminal:-ghostty}"
    case "$terminal" in
        ghostty|wezterm|both|none) ;;
        *) printf 'Invalid terminal: %s (expected ghostty, wezterm, both or none)\n' "$terminal" >&2; return 2 ;;
    esac
}

terminal_menu() {
    local answer
    while :; do
        printf '\nTerminal emulator (default: %s):\n  1) Ghostty\n  2) WezTerm\n  3) Both\n  4) None\nChoose [1-4, Enter for default]: ' "$terminal"
        read -r answer || return 1
        case "$answer" in
            '') break ;;
            1|ghostty) terminal=ghostty; break ;;
            2|wezterm) terminal=wezterm; break ;;
            3|both) terminal=both; break ;;
            4|none) terminal=none; break ;;
            *) echo 'Choose 1, 2, 3 or 4.' ;;
        esac
    done
}

terminal_choose() {
    local explicit="${DOTFILES_TERMINAL:-}"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --terminal)
                [[ $# -ge 2 && -n "$2" ]] || { echo '--terminal requires a value.' >&2; return 2; }
                explicit="$2"; shift 2 ;;
            --help|-h)
                echo 'Usage: bootstrap [--terminal ghostty|wezterm|both|none]'
                echo 'Interactive menu; saved choice or Ghostty is the default.'
                exit 0 ;;
            *) printf 'Unknown option: %s\n' "$1" >&2; return 2 ;;
        esac
    done
    DOTFILES_TERMINAL="$explicit" terminal_load || return
    if [[ -z "$explicit" && -t 0 && -z "${NONINTERACTIVE:-}" ]]; then
        terminal_menu || return
    fi
    export DOTFILES_TERMINAL="$terminal"
    mkdir -p "$(dirname "$terminal_state")" || return
    printf '%s\n' "$terminal" > "$terminal_state" || return
    printf 'Terminal selection: %s\n' "$terminal"
}

terminal_skip_casks() {
    local package
    for package in wezterm ghostty; do
        if [[ "$terminal" != both && "$terminal" != "$package" ]]; then
            HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:+$HOMEBREW_BUNDLE_CASK_SKIP }$package"
        fi
    done
    export HOMEBREW_BUNDLE_CASK_SKIP
}

terminal_link_enabled() {
    case "$1" in
        wezterm/*|ghostty/*) [[ "$terminal" == both || "$terminal" == "${1%%/*}" ]] ;;
        *) return 0 ;;
    esac
}
