#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
removed_count=0
skipped_count=0

print_header() {
    echo -e "${CYAN}=== Dotfiles Uninstallation ===${NC}"
    echo -e "${GRAY}This removes only symlinks managed by this repository.${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error() { echo -e "${RED}$1${NC}"; }

resolve_path() {
    local path="$1"
    printf '%s/%s\n' "$(cd -P "$(dirname "$path")" && pwd)" "$(basename "$path")"
}

points_to_source() {
    local source="$1" target="$2" link_target candidate
    link_target="$(readlink "$target")"
    candidate="$link_target"
    [[ "$candidate" == /* ]] || candidate="$(dirname "$target")/$candidate"
    [[ "$(resolve_path "$candidate")" == "$(resolve_path "$source")" ]]
}

print_header
print_warning "Remove managed dotfiles symlinks? (y/n)"
read -r confirm || confirm=""
if [[ "$confirm" != "y" ]]; then
    echo -e "${GRAY}Uninstallation cancelled.${NC}"
    exit 0
fi

for entry in \
    "$DOTFILES_DIR/wezterm/.wezterm.lua|$HOME/.wezterm.lua|WezTerm" \
    "$DOTFILES_DIR/starship/starship.toml|$HOME/.config/starship.toml|Starship" \
    "$DOTFILES_DIR/nvim|$HOME/.config/nvim|Neovim" \
    "$DOTFILES_DIR/gitui/key_bindings.ron|$HOME/.config/gitui/key_bindings.ron|gitui" \
    "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc|zsh"; do
    IFS='|' read -r source target name <<< "$entry"
    echo -e "${CYAN}Processing $name...${NC}"

    if [[ ! -e "$target" && ! -L "$target" ]]; then
        print_warning "  ⚠ Not found"
        ((skipped_count += 1))
    elif [[ ! -L "$target" ]]; then
        print_warning "  ⚠ Not a symlink — preserving it"
        ((skipped_count += 1))
    elif ! points_to_source "$source" "$target"; then
        print_warning "  ⚠ Points outside this repository — preserving it"
        ((skipped_count += 1))
    elif rm -f "$target"; then
        print_success "  ✓ Removed symlink"
        ((removed_count += 1))
    else
        print_error "  ✗ Failed to remove"
        ((skipped_count += 1))
    fi
done

echo ""
echo -e "${CYAN}=== Summary ===${NC}"
print_success "Removed: $removed_count symlink(s)"
[[ $skipped_count -eq 0 ]] || print_warning "Skipped: $skipped_count item(s)"
