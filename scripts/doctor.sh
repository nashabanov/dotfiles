#!/usr/bin/env bash
# Read-only diagnostics: no installs, network requests, or configuration startup.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
passed=0
failed=0
warnings=0
red='' green='' yellow='' cyan='' reset=''
if [[ -z "${NO_COLOR+x}" && "${FORCE_COLOR:-}" != 0 ]] && \
    { [[ -n "${FORCE_COLOR:-}" ]] || [[ -t 1 && "${TERM:-dumb}" != dumb ]]; }; then
    red=$'\033[31m'
    green=$'\033[32m'
    yellow=$'\033[33m'
    cyan=$'\033[1;36m'
    reset=$'\033[0m'
fi
report() {
    local status="$1" name="$2" detail="$3" color=''
    case "$status" in
        OK) color="$green" ;;
        FAIL) color="$red" ;;
        WARN) color="$yellow" ;;
    esac
    printf '  %s[%-4s]%s %-32s %s\n' "$color" "$status" "$reset" "$name" "$detail"
    case "$status" in
        OK) passed=$((passed + 1)) ;;
        FAIL) failed=$((failed + 1)) ;;
        WARN) warnings=$((warnings + 1)) ;;
    esac
}
section() { printf '\n%s%s%s\n' "$cyan" "$1" "$reset"; }
check_binary() {
    local binary="$1" hint="$2" location
    if location="$(command -v "$binary" 2>/dev/null)"; then
        report OK "$binary" "$location"
    else
        report FAIL "$binary" "missing from PATH; $hint"
    fi
}
printf 'Dotfiles doctor\nRepository: %s\nHome: %s\n' "$ROOT" "$HOME"
section 'System and Homebrew binaries'
for binary in bash zsh git make curl cc; do
    check_binary "$binary" 'install system / Xcode command line tools'
done
check_binary brew 'install Homebrew'
if binaries="$(inventory "$ROOT" brew-binaries)"; then
    while IFS= read -r binary; do
        [[ -z "$binary" ]] || check_binary "$binary" 'run make brew-install'
    done <<< "$binaries"
else
    report FAIL 'Brewfile inventory' 'could not read inventory'
fi
# Applications may be installed without a CLI exposed in PATH.
if apps="$(inventory "$ROOT" brew-apps)"; then
    while IFS= read -r app; do
        [[ -z "$app" ]] && continue
        binary="${app##*/}"
        if command -v "$binary" >/dev/null 2>&1; then
            check_binary "$binary" 'run make brew-install'
        elif [[ -x "/Applications/$app" ]]; then
            report OK "$binary" "/Applications/$app"
        elif [[ -x "$HOME/Applications/$app" ]]; then
            report OK "$binary" "$HOME/Applications/$app"
        else
            report FAIL "$binary" 'application missing; run make brew-install'
        fi
    done <<< "$apps"
else
    report FAIL 'Application inventory' 'could not read inventory'
fi
section 'mise binaries: CLI, formatters, linters and language servers'
if binaries="$(inventory "$ROOT" mise-binaries)"; then
    while IFS= read -r binary; do
        [[ -z "$binary" ]] || check_binary "$binary" 'run make tools-install; check mise activation'
    done <<< "$binaries"
else
    report FAIL 'mise inventory' 'could not read inventory'
fi
if command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        report OK 'FZF shell integration' 'fzf --zsh available'
    else
        report FAIL 'FZF shell integration' 'fzf --zsh failed; run make tools-install'
    fi
fi
section 'Managed symlinks'
while IFS='|' read -r source target _name; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    source="$ROOT/$source"
    target="$HOME/$target"
    if [[ ! -e "$source" ]]; then
        report FAIL "$target" "repository source missing: $source"
    elif [[ ! -L "$target" ]]; then
        if [[ -e "$target" ]]; then
            report FAIL "$target" 'exists but is not a symlink; review before make links'
        else
            report FAIL "$target" 'missing; run make links'
        fi
    elif [[ ! -e "$target" ]]; then
        report FAIL "$target" "broken link -> $(readlink "$target"); run make links"
    elif [[ "$target" -ef "$source" ]]; then
        report OK "$target" "-> $(readlink "$target")"
    else
        report FAIL "$target" "wrong destination -> $(readlink "$target"); run make links"
    fi
done < "$ROOT/symlinks.conf"
section 'Homebrew packages and Zsh integrations'
if command -v brew >/dev/null 2>&1; then
    if output="$(HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --no-upgrade --file="$ROOT/Brewfile" 2>&1)"; then
        report OK Brewfile 'all formulae, casks and fonts installed'
    else
        report FAIL Brewfile 'missing dependencies; run make brew-install'
        printf '%s\n' "$output"
    fi
    if prefix="$(brew --prefix 2>/dev/null)"; then
        if files="$(inventory "$ROOT" brew-files)"; then
            while IFS= read -r path; do
                [[ -z "$path" ]] && continue
                if [[ -r "$prefix/$path" ]]; then
                    report OK "$path" "$prefix/$path"
                else
                    report FAIL "$path" 'missing or unreadable; run make brew-install'
                fi
            done <<< "$files"
        else
            report FAIL 'Brewfile files' 'could not read inventory'
        fi
    else
        report FAIL 'Homebrew prefix' 'brew --prefix failed'
    fi
else
    report WARN 'Homebrew integrations' 'skipped: brew unavailable'
fi
section 'Shell configuration syntax'
for file in "$ROOT"/*.sh "$ROOT"/lib/*.sh "$ROOT"/tests/*.sh; do
    if output="$(bash -n "$file" 2>&1)"; then
        report OK "${file#"$ROOT/"}" 'bash syntax valid'
    else
        report FAIL "${file#"$ROOT/"}" "$output"
    fi
done
if command -v zsh >/dev/null 2>&1; then
    for file in "$ROOT/zsh/.zshrc" "$ROOT"/zsh/*.zsh; do
        if output="$(zsh -n "$file" 2>&1)"; then
            report OK "${file#"$ROOT/"}" 'zsh syntax valid'
        else
            report FAIL "${file#"$ROOT/"}" "$output"
        fi
    done
else
    report WARN 'Zsh syntax' 'skipped: zsh unavailable'
fi
section 'Neovim and shell environment'
lazy_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
if [[ -r "$lazy_dir/lua/lazy/init.lua" ]]; then
    report OK 'lazy.nvim' "$lazy_dir"
else
    report WARN 'lazy.nvim' 'not bootstrapped; launch nvim to install plugins'
fi
if [[ "${SHELL:-}" == */zsh ]]; then
    report OK 'Login shell' "$SHELL"
else
    report WARN 'Login shell' "${SHELL:-unset}; configuration targets zsh"
fi
if [[ -n "${ZDOTDIR:-}" && "$ZDOTDIR" != "$HOME" ]]; then
    report WARN ZDOTDIR "$ZDOTDIR; zsh may not load the managed ~/.zshrc"
fi
if [[ -n "${XDG_CONFIG_HOME:-}" && "$XDG_CONFIG_HOME" != "$HOME/.config" ]]; then
    report WARN XDG_CONFIG_HOME "$XDG_CONFIG_HOME; installer links configurations under ~/.config"
fi
printf '\nSummary: %s%d passed%s, %s%d failed%s, %s%d warnings%s\n' \
    "$green" "$passed" "$reset" "$red" "$failed" "$reset" "$yellow" "$warnings" "$reset"
[[ "$failed" -eq 0 ]]
