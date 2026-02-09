#!/usr/bin/env bash
set -euo pipefail

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

declare -a SYMLINKS=(
    "$HOME/.wezterm.lua:WezTerm"
    "$HOME/.config/starship.toml:Starship"
    "$HOME/.config/nvim:Neovim"
    "$HOME/.config/gitui/key_bindings.ron:gitui"
)

print_header() {
    echo -e "${CYAN}=== Dotfiles Uninstallation ===${NC}"
    echo -e "${GRAY}This will remove symlinks created by install.sh${NC}"
    echo ""
}

print_info()    { echo -e "${CYAN}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error()   { echo -e "${RED}$1${NC}"; }

print_header
print_warning "Are you sure you want to remove all dotfiles symlinks? (y/n)"
read -r confirm
if [[ "${confirm:-n}" != "y" ]]; then
    echo -e "${GRAY}Uninstallation cancelled.${NC}"
    exit 0
fi

echo ""

removed_count=0
skipped_count=0

for entry in "${SYMLINKS[@]}"; do
    target="${entry%%:*}"
    name="${entry##*:}"
    
    echo -e "${CYAN}Processing $name...${NC}"
    
    if [[ ! -e "$target" ]]; then
        print_warning "  ⚠ Not found (already removed or never created)"
        ((skipped_count++))
        echo ""
        continue
    fi
    
    if [[ -L "$target" ]]; then
        target_path="$(readlink "$target")"
        echo -e "  ${GRAY}→ Target: $target_path${NC}"
        
        if rm -f "$target" 2>/dev/null; then
            print_success "  ✓ Removed symlink"
            ((removed_count++))
        else
            print_error "  ✗ Failed to remove"
            ((skipped_count++))
        fi
    else
        print_warning "  ⚠ NOT A SYMLINK — skipped (preserving original file)"
        ((skipped_count++))
    fi
    echo ""
done

echo -e "${CYAN}=== Summary ===${NC}"
print_success "Removed: $removed_count symlink(s)"

if [[ $skipped_count -gt 0 ]]; then
    print_warning "Skipped: $skipped_count item(s)"
fi

echo ""
echo -e "${GRAY}Your dotfiles repository remains intact at:${NC}"
echo -e "${GRAY}$DOTFILES_DIR${NC}"
echo ""
echo -e "${CYAN}Tip:${NC} Run ${GREEN}./install.sh${NC} to restore symlinks later."
