#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/terminal.sh
source "$ROOT/lib/terminal.sh"
terminal_choose "$@"
make -C "$ROOT" brew-install
make -C "$ROOT" links
make -C "$ROOT" tools-install
