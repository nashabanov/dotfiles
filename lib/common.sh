#!/usr/bin/env bash
# Use a real Python executable: invoking a mise shim could install tools or
# resolve remote versions while doctor is supposed to be read-only.
inventory() (
    root="$1" mode="$2"
    # shellcheck source=lib/terminal.sh
    source "$root/lib/terminal.sh"
    terminal_load || return
    terminal_skip_casks
    for python in python3.13 python3; do
        remaining="${PATH:-}"
        while [[ -n "$remaining" ]]; do
            directory="${remaining%%:*}"
            if [[ "$remaining" == *:* ]]; then remaining="${remaining#*:}"; else remaining=''; fi
            case "$directory" in */mise/shims|*/mise/shims/|'') continue ;; esac
            candidate="$directory/$python"
            if [[ -x "$candidate" ]] && "$candidate" -c 'import tomllib' 2>/dev/null; then
                "$candidate" "$root/lib/inventory.py" "$root" "$mode"
                return
            fi
        done
    done
    echo 'Inventory needs a real Python >=3.11 executable; activate mise or install Python.' >&2
    return 1
)
