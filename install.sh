#!/usr/bin/env bash
set -euo pipefail

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEZTERM_SOURCE="$DOTFILES_DIR/wezterm/.wezterm.lua"
STARSHIP_SOURCE="$DOTFILES_DIR/starship/starship.toml"
NVIM_SOURCE="$DOTFILES_DIR/nvim"
GITUI_SOURCE="$DOTFILES_DIR/gitui/key_bindings.ron"

WEZTERM_TARGET="$HOME/.wezterm.lua"
STARSHIP_TARGET="$HOME/.config/starship.toml"
NVIM_TARGET="$HOME/.config/nvim"
GITUI_TARGET="$HOME/.config/gitui/key_bindings.ron"

success_count=0
fail_count=0

print_header() {
    echo -e "${CYAN}=== Dotfiles Installation ===${NC}"
    echo -e "${GRAY}Repository: $DOTFILES_DIR${NC}"
    echo ""
}

print_info()    { echo -e "${CYAN}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error()   { echo -e "${RED}$1${NC}"; }

create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [[ ! -e "$source" ]]; then
        print_error "✗ Source not found: $source"
        ((fail_count++))
        return 1
    fi

    local parent_dir="$(dirname "$target")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir" 2>/dev/null || {
            print_error "✗ Cannot create directory: $parent_dir"
            ((fail_count++))
            return 1
        }
        print_info "  → Created directory: $parent_dir"
    fi

    if [[ -L "$target" ]]; then
        rm -f "$target"
        print_warning "  → Removed existing symlink: $target"
    elif [[ -e "$target" ]]; then
        print_warning "  ⚠ $target already exists (not a symlink). Replace? (y/n)"
        read -r response
        if [[ "${response:-n}" != "y" ]]; then
            print_warning "  → Skipped: $target"
            ((fail_count++))
            return 1
        fi
        rm -rf "$target"
        print_warning "  → Deleted: $target"
    fi

    if ln -sfn "$source" "$target" 2>/dev/null; then
        local type="file"
        [[ -d "$source" ]] && type="directory"
        print_success "✓ Symlink created ($type):"
        echo -e "    ${GRAY}$target${NC}"
        echo -e "    ${GRAY}  → $source${NC}"
        ((success_count++))
        return 0
    else
        print_error "✗ Failed to create symlink: $target"
        ((fail_count++))
        return 1
    fi
}

print_header

echo -e "${CYAN}Creating symlinks...${NC}"
echo ""

create_symlink "$WEZTERM_SOURCE" "$WEZTERM_TARGET" "WezTerm"
create_symlink "$STARSHIP_SOURCE" "$STARSHIP_TARGET" "Starship"
create_symlink "$NVIM_SOURCE" "$NVIM_TARGET" "Neovim"
create_symlink "$GITUI_SOURCE" "$GITUI_TARGET" "gitui"

echo ""
print_header="=== Summary ==="
echo -e "${CYAN}${print_header}${NC}"

if [[ $success_count -eq 4 && $fail_count -eq 0 ]]; then
    print_success "✓ Installation complete! All symlinks created successfully."
    exit 0
elif [[ $success_count -gt 0 ]]; then
    print_warning "⚠ Installation partially complete"
    print_success "  Success: $success_count symlink(s)"
    print_error "  Failed:  $fail_count symlink(s)"
    exit 1
else
    print_error "✗ Installation failed! No symlinks were created."
    echo -e "${YELLOW}Please fix the errors above and try again.${NC}"
    exit 1
fi
