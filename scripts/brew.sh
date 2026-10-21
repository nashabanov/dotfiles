#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/terminal.sh
source "$ROOT/lib/terminal.sh"
terminal_load
terminal_skip_casks
exec brew bundle "$@" --file="$ROOT/Brewfile"
