#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
success_count=0
fail_count=0

print_header() {
    echo -e "${CYAN}=== Dotfiles Symlinks ===${NC}"
    echo -e "${GRAY}Repository: $DOTFILES_DIR${NC}"
    echo ""
}

print_info() { echo -e "${CYAN}$1${NC}"; }
print_success() { echo -e "${GREEN}$1${NC}"; }
print_warning() { echo -e "${YELLOW}$1${NC}"; }
print_error() { echo -e "${RED}$1${NC}"; }

create_symlink() {
    local source="$1" target="$2" name="$3" response parent_dir
    print_info "Processing $name..."

    if [[ ! -e "$source" ]]; then
        print_error "  ✗ Source not found: $source"
        ((fail_count += 1))
        return 1
    fi

    parent_dir="$(dirname "$target")"
    if [[ ! -d "$parent_dir" ]]; then
        if ! mkdir -p "$parent_dir"; then
            print_error "  ✗ Cannot create directory: $parent_dir"
            ((fail_count += 1))
            return 1
        fi
        print_info "  → Created directory: $parent_dir"
    fi

    if [[ -L "$target" ]]; then
        if [[ "$(readlink "$target")" == "$source" ]]; then
            print_success "  ✓ Already linked"
            ((success_count += 1))
            return 0
        fi
        rm -f "$target"
        print_warning "  → Replaced existing symlink: $target"
    elif [[ -e "$target" ]]; then
        print_warning "  ⚠ $target already exists (not a symlink). Replace? (y/n)"
        read -r response || response=""
        if [[ "$response" != "y" ]]; then
            print_warning "  → Skipped: $target"
            ((fail_count += 1))
            return 1
        fi
        rm -rf "$target"
        print_warning "  → Deleted: $target"
    fi

    if ln -s "$source" "$target"; then
        print_success "  ✓ Linked: $target → $source"
        ((success_count += 1))
        return 0
    fi

    print_error "  ✗ Failed to create symlink: $target"
    ((fail_count += 1))
    return 1
}

print_header
# Keep stdin available for replacement confirmations.
while IFS='|' read -r source target name <&3; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    create_symlink "$DOTFILES_DIR/$source" "$HOME/$target" "$name" || :
done 3< "$DOTFILES_DIR/symlinks.conf"

echo ""
echo -e "${CYAN}=== Summary ===${NC}"
if [[ $fail_count -eq 0 ]]; then
    print_success "✓ Symlinks ready: $success_count symlink(s) ready."
    exit 0
fi

print_warning "⚠ Symlinks incomplete"
print_success "  Success: $success_count symlink(s)"
print_error "  Failed:  $fail_count symlink(s)"
exit 1
