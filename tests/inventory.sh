#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/repo/mise" "$fixture/home"
cp "$ROOT/Brewfile" "$ROOT/symlinks.conf" "$ROOT/symlinks.sh" "$ROOT/doctor.sh" "$ROOT/uninstall.sh" "$fixture/repo/"
cp -R "$ROOT/lib" "$fixture/repo/"
cp "$ROOT/mise/config.toml" "$fixture/repo/mise/"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
printf '\nfresh-cli = "latest"\n"npm:example" = "latest" # doctor: example-server\n' >> "$fixture/repo/mise/config.toml"
printf '\nbrew "fresh-brew"\nbrew "renamed" # doctor: actual-command\n' >> "$fixture/repo/Brewfile"
commands="$(inventory "$fixture/repo" mise-binaries)"
[[ $'\n'"$commands"$'\n' == *$'\n'fresh-cli$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'example-server$'\n'* ]]
commands="$(inventory "$fixture/repo" brew-binaries)"
[[ $'\n'"$commands"$'\n' == *$'\n'fresh-brew$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'actual-command$'\n'* ]]
# A new link needs only one manifest edit for install, doctor and uninstall.
printf 'extra|.extra|Extra\n' >> "$fixture/repo/symlinks.conf"
while IFS='|' read -r source _target _name; do
    [[ -z "$source" || "$source" == \#* ]] && continue
    [[ -e "$fixture/repo/$source" ]] && continue
    mkdir -p "$(dirname "$fixture/repo/$source")"
    printf 'fixture\n' > "$fixture/repo/$source"
done < "$fixture/repo/symlinks.conf"
HOME="$fixture/home" bash "$fixture/repo/symlinks.sh" >/dev/null
[[ -L "$fixture/home/.extra" ]]
output="$(HOME="$fixture/home" bash "$fixture/repo/doctor.sh" 2>&1)" || :
[[ "$output" == *"$fixture/home/.extra"* && "$output" == *fresh-cli* && "$output" == *actual-command* ]]
HOME="$fixture/home" bash "$fixture/repo/uninstall.sh" --links-only --yes >/dev/null
[[ ! -L "$fixture/home/.extra" ]]
printf '\n[tools.table-cli]\nversion = "latest"\n' >> "$fixture/repo/mise/config.toml"
tools="$(inventory "$fixture/repo" mise-tools)"
[[ "$tools" == *table-cli* && "$tools" != *$'\n'version* ]]
echo 'PASS: inventories follow manifest edits, renamed commands and TOML tables'
