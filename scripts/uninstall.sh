#!/usr/bin/env bash
# Remove the environment declared by this repository, never run during tests
# against the real package managers. Preview is available without confirmation.
set -eo pipefail
# macOS Bash 3.2 treats empty arrays as unset under nounset.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
dry_run=0
assume_yes=0
links_only=0
purge_data=0
failures=0
usage() {
    cat <<'HELP'
Usage: bash scripts/uninstall.sh [--dry-run] [--yes] [--links-only] [--purge-data]
  Default: managed links, all installed versions of mise tools declared here,
           installed Brewfile packages/apps/fonts, and application caches.
  --dry-run     Print the exact removal plan without changing anything.
  --yes         Apply the printed plan without interactive confirmation.
  --links-only  Remove only links pointing to this repository.
  --purge-data  Also remove Neovim data/state and WezTerm plugin data, and zap
                Brewfile casks (OrbStack VM/container data may be deleted).
Homebrew, repository files, foreign configurations and credentials are preserved.
Tools declared here may also be used by other projects.
HELP
}
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=1 ;;
        --yes|-y) assume_yes=1 ;;
        --links-only) links_only=1 ;;
        --purge-data) purge_data=1 ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
    esac
done
if [[ "$links_only" -eq 1 && "$purge_data" -eq 1 ]]; then
    echo '--links-only and --purge-data cannot be combined.' >&2
    exit 2
fi
[[ "${HOME:-}" == /* && "$HOME" != / ]] || { echo 'HOME must be an absolute non-root path.' >&2; exit 2; }
links=()
paths=()
formulae=()
casks=()
tools=()
# -ef handles relative symlinks; exact targets also allow broken managed links.
while IFS='|' read -r source target _name; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    source="$ROOT/$source"; target="$HOME/$target"
    if [[ -L "$target" ]] && { [[ "$target" -ef "$source" ]] || [[ "$(readlink "$target")" == "$source" ]]; }; then
        links+=("$target")
    elif [[ -e "$target" || -L "$target" ]]; then
        printf 'Preserve foreign configuration: %s\n' "$target"
    fi
done < "$ROOT/symlinks.conf"
if [[ "$links_only" -eq 0 ]]; then
    # Read manifests before removing managers or configuration links.
    if command -v mise >/dev/null 2>&1; then
        declared_tools="$(inventory "$ROOT" mise-tools)"
        while IFS= read -r tool; do
            [[ -z "$tool" ]] || tools+=("$tool")
        done <<< "$declared_tools"
    else
        echo 'WARNING: mise unavailable; tools cannot be uninstalled.' >&2
        failures=$((failures + 1))
    fi
    if command -v brew >/dev/null 2>&1; then
        installed_formulae="$(brew list --formula)"
        installed_casks="$(brew list --cask)"
        declared_formulae="$(brew bundle list --formula --file="$ROOT/Brewfile")"
        declared_casks="$(brew bundle list --cask --file="$ROOT/Brewfile")"
        while IFS= read -r package; do
            [[ -n "$package" ]] || continue
            if [[ $'\n'"$installed_formulae"$'\n' == *$'\n'"$package"$'\n'* ]]; then
                formulae+=("$package")
            fi
        done <<< "$declared_formulae"
        while IFS= read -r package; do
            [[ -n "$package" ]] || continue
            if [[ $'\n'"$installed_casks"$'\n' == *$'\n'"$package"$'\n'* ]]; then
                casks+=("$package")
            fi
        done <<< "$declared_casks"
    else
        echo 'WARNING: brew unavailable; Brewfile packages cannot be uninstalled.' >&2
        failures=$((failures + 1))
    fi
    paths+=("${XDG_CACHE_HOME:-$HOME/.cache}/nvim" "${XDG_CACHE_HOME:-$HOME/.cache}/starship")
    if [[ "$purge_data" -eq 1 ]]; then
        paths+=("${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
                "${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
                "${XDG_DATA_HOME:-$HOME/.local/share}/wezterm")
    fi
fi
# Canonicalize through existing ancestors, including symlinked XDG roots.
physical_path() {
    local candidate="$1" suffix=''
    while [[ ! -d "$candidate" ]]; do
        suffix="/$(basename "$candidate")$suffix"
        candidate="$(dirname "$candidate")"
    done
    printf '%s%s\n' "$(cd -P "$candidate" && pwd)" "$suffix"
}
repo_physical="$(cd -P "$ROOT" && pwd)"
home_physical="$(cd -P "$HOME" && pwd)"
validate_cleanup_path() {
    local path="$1" resolved
    [[ "$path" == /* && "$path" != *'/../'* && "$path" != *'/./'* && "$path" != /nvim && "$path" != /starship && "$path" != /wezterm ]] || {
        printf 'Unsafe cleanup path: %s\n' "$path" >&2; return 1;
    }
    resolved="$(physical_path "$path")"
    # Protect both repository descendants and its ancestors; allow HOME children.
    if [[ "$resolved/" == "$repo_physical/"* || "$repo_physical/" == "$resolved/"* || "$home_physical/" == "$resolved/"* ]]; then
        printf 'Refusing cleanup path intersecting repository or enclosing HOME: %s\n' "$path" >&2
        return 1
    fi
}
for path in "${paths[@]}"; do validate_cleanup_path "$path" || exit 2; done
printf '\nRemoval plan (repository and Homebrew are preserved):\n'
for target in "${links[@]}"; do printf '  symlink: %s\n' "$target"; done
for tool in "${tools[@]}"; do printf '  mise tool (all versions): %s\n' "$tool"; done
for package in "${casks[@]}"; do printf '  cask: %s (purge data: %s)\n' "$package" "$purge_data"; done
for package in "${formulae[@]}"; do printf '  formula: %s\n' "$package"; done
for path in "${paths[@]}"; do printf '  directory: %s\n' "$path"; done
if [[ "$failures" -gt 0 ]]; then
    echo 'Preflight failed; no changes made.' >&2
    exit 1
fi
if [[ "$dry_run" -eq 1 ]]; then exit 0; fi
if [[ "$assume_yes" -eq 0 ]]; then
    printf '\nApply this removal plan? [y/N] '
    read -r confirm || confirm=''
    [[ "$confirm" == y ]] || { echo 'Cancelled.'; exit 0; }
fi
run() {
    if ! "$@"; then
        printf 'FAILED:' >&2; printf ' %q' "$@" >&2; printf '\n' >&2
        echo "Cleanup stopped; later stages and configuration links are preserved." >&2
        return 1
    fi
}
# Keep config links and managers available until mise has finished.
if [[ ${#tools[@]} -gt 0 ]]; then
    run mise -C "$ROOT" uninstall --all "${tools[@]}"
fi
if [[ ${#casks[@]} -gt 0 ]]; then
    if [[ "$purge_data" -eq 1 ]]; then
        run brew uninstall --cask --zap "${casks[@]}"
    else
        run brew uninstall --cask "${casks[@]}"
    fi
fi
# One batch lets Homebrew resolve dependencies among the declared formulae.
# No --ignore-dependencies: packages needed by remaining software are protected.
if [[ ${#formulae[@]} -gt 0 ]]; then
    run brew uninstall --formula "${formulae[@]}"
fi
for target in "${links[@]}"; do run rm -f -- "$target"; done
for path in "${paths[@]}"; do
    validate_cleanup_path "$path"
    run rm -rf -- "$path"
done
printf '\nCleanup finished successfully.\n'
