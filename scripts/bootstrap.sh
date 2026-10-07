#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Homebrew's installer does not update this process's PATH.
if ! command -v brew >/dev/null 2>&1; then
    for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
        if [[ -x "$brew_path" ]]; then
            eval "$("$brew_path" shellenv)"
            break
        fi
    done
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise..."
    brew install mise
fi

make -C "$DOTFILES_DIR" bootstrap
