#!/usr/bin/env bash
# Select a real Python without invoking mise shims or loading user configuration.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
# shellcheck source=lib/terminal.sh
source "$ROOT/lib/terminal.sh"
terminal_load || exit $?
terminal_skip_casks
export DOTFILES_TERMINAL="$terminal"
run_python "$ROOT/lib/doctor.py" "$ROOT"
