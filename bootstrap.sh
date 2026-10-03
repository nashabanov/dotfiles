#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v mise >/dev/null 2>&1; then
    echo "Installing mise..."
    brew install mise
fi

make bootstrap
