#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
doctor_home="$(mktemp -d)"
trap 'rm -rf "$doctor_home"' EXIT
HOME="$doctor_home" bash "$ROOT/scripts/symlinks.sh" >/dev/null
run_doctor() {
    local status=0
    output="$(HOME="$doctor_home" bash "$ROOT/scripts/doctor.sh" 2>&1)" || status=$?
    # Other machine dependencies may be missing; assert individual diagnostics.
    [[ "$status" -le 1 ]]
}
assert_diagnostic() {
    local status="$1" detail="$2"
    printf '%s\n' "$output" | awk -v target="$doctor_home/.zshrc" \
        -v status="$status" -v detail="$detail" \
        'index($0, target) && index($0, "[" status) && index($0, detail) { found=1 }
         END { exit !found }'
}
run_doctor
assert_diagnostic OK '->'
rm "$doctor_home/.zshrc"
# Equivalent relative links are healthy too.
mkdir "$doctor_home/config"
ln -s "$ROOT/zsh" "$doctor_home/config/zsh"
ln -s 'config/zsh/.zshrc' "$doctor_home/.zshrc"
run_doctor
assert_diagnostic OK '->'
rm "$doctor_home/.zshrc"
ln -s "$doctor_home/missing" "$doctor_home/.zshrc"
run_doctor
assert_diagnostic FAIL 'broken link'
[[ "$(readlink "$doctor_home/.zshrc")" == "$doctor_home/missing" ]]
rm "$doctor_home/.zshrc"
ln -s "$ROOT/README.md" "$doctor_home/.zshrc"
run_doctor
assert_diagnostic FAIL 'wrong destination'
[[ "$(readlink "$doctor_home/.zshrc")" == "$ROOT/README.md" ]]
rm "$doctor_home/.zshrc"
printf 'keep me\n' > "$doctor_home/.zshrc"
run_doctor
assert_diagnostic FAIL 'not a symlink'
[[ "$(cat "$doctor_home/.zshrc")" == 'keep me' ]]
rm "$doctor_home/.zshrc"
run_doctor
assert_diagnostic FAIL 'missing;'
echo 'PASS: doctor checks symlink states without modifying configuration'

# The launcher must skip mise shims, even when they precede real Python.
mkdir -p "$doctor_home/mise/shims"
cat > "$doctor_home/mise/shims/python3.13" <<'STUB'
#!/bin/bash
printf 'unexpected shim invocation\n' > "$HOME/shim-called"
exit 99
STUB
cp "$doctor_home/mise/shims/python3.13" "$doctor_home/mise/shims/python3"
chmod +x "$doctor_home/mise/shims/"*
output="$(PATH="$doctor_home/mise/shims:$PATH" HOME="$doctor_home" NO_COLOR=1 FORCE_COLOR=1 bash "$ROOT/scripts/doctor.sh" 2>&1)" || :
[[ ! -e "$doctor_home/shim-called" && "$output" == *'Summary:'* ]]
[[ "$output" != *$'\033['* ]]

# Malformed inventory is a diagnostic failure, not a traceback or an early exit.
mkdir -p "$doctor_home/repo/scripts" "$doctor_home/repo/mise"
cp "$ROOT/scripts/doctor.sh" "$doctor_home/repo/scripts/"
cp -R "$ROOT/lib" "$doctor_home/repo/"
cp "$ROOT/Brewfile" "$ROOT/symlinks.conf" "$doctor_home/repo/"
printf '[tools\n' > "$doctor_home/repo/mise/config.toml"
status=0
output="$(HOME="$doctor_home" bash "$doctor_home/repo/scripts/doctor.sh" 2>&1)" || status=$?
[[ "$status" == 1 && "$output" == *'could not read inventory'* ]]
[[ "$output" == *'Summary:'* && "$output" != *Traceback* ]]
[[ ! -d "$doctor_home/repo/lib/__pycache__" ]]
echo 'PASS: doctor skips mise shims, honors NO_COLOR and reports invalid inventories'
