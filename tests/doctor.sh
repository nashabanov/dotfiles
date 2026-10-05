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
