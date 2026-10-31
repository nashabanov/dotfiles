#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin"
export UPDATE_LOG="$fixture/log"
cat > "$fixture/bin/mise" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$UPDATE_LOG"
if [[ "$3" == upgrade ]]; then exit "${FAIL_UPGRADE:-0}"; fi
STUB
chmod +x "$fixture/bin/mise"
export PATH="$fixture/bin:$PATH"
# Resolve the repository even when invoked through the global config symlink.
ln -s "$ROOT/mise" "$fixture/config"
cd "$fixture"
bash "$fixture/config/tasks/tools/update"
expected="$(printf '%s\n' "-C $ROOT upgrade" "-C $ROOT run zsh-completions-sync")"
[[ "$(cat "$UPDATE_LOG")" == "$expected" ]]
: > "$UPDATE_LOG"
status=0
FAIL_UPGRADE=7 bash "$ROOT/mise/tasks/tools/update" || status=$?
[[ "$status" == 7 && "$(cat "$UPDATE_LOG")" == "-C $ROOT upgrade" ]]
echo 'PASS: tools:update refreshes completions only after a successful upgrade'
