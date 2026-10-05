#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/repo/mise/conf.d" "$fixture/repo/scripts" "$fixture/home"
cp "$ROOT/Brewfile" "$ROOT/symlinks.conf" "$fixture/repo/"
cp "$ROOT/scripts/symlinks.sh" "$ROOT/scripts/doctor.sh" "$ROOT/scripts/uninstall.sh" "$fixture/repo/scripts/"
cp -R "$ROOT/lib" "$fixture/repo/"
cp "$ROOT/mise/config.toml" "$fixture/repo/mise/"
printf '[tools]\n"npm:editor-fixture" = "latest" # doctor: editor-fixture-server\n' > "$fixture/repo/mise/conf.d/nvim.toml"
# shellcheck source=lib/common.sh
source "$ROOT/lib/common.sh"
printf '\nfresh-cli = "latest"\n"npm:example" = "latest" # doctor: example-server\n' >> "$fixture/repo/mise/config.toml"
printf '\nbrew "fresh-brew"\nbrew "renamed" # doctor: actual-command\n' >> "$fixture/repo/Brewfile"
commands="$(inventory "$fixture/repo" mise-binaries)"
[[ $'\n'"$commands"$'\n' == *$'\n'uv$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'uvx$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'fresh-cli$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'example-server$'\n'* ]]
[[ $'\n'"$commands"$'\n' == *$'\n'editor-fixture-server$'\n'* ]]
tools="$(inventory "$fixture/repo" mise-tools)"
[[ $'\n'"$tools"$'\n' == *$'\n'fresh-cli$'\n'* ]]
[[ $'\n'"$tools"$'\n' == *$'\n'npm:editor-fixture$'\n'* ]]
commands="$(inventory "$fixture/repo" brew-binaries)"
[[ $'\n'"$commands"$'\n' != *$'\n'uv$'\n'* ]]
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
HOME="$fixture/home" bash "$fixture/repo/scripts/symlinks.sh" >/dev/null
[[ -L "$fixture/home/.extra" ]]
[[ -L "$fixture/home/.config/git/config" && -L "$fixture/home/.config/git/ignore" ]]
output="$(HOME="$fixture/home" bash "$fixture/repo/scripts/doctor.sh" 2>&1)" || :
[[ "$output" == *"$fixture/home/.extra"* && "$output" == *fresh-cli* && "$output" == *actual-command* ]]
HOME="$fixture/home" bash "$fixture/repo/scripts/uninstall.sh" --links-only --yes >/dev/null
[[ ! -L "$fixture/home/.extra" ]]
printf '\n[tools.table-cli]\nversion = "latest"\n' >> "$fixture/repo/mise/config.toml"
tools="$(inventory "$fixture/repo" mise-tools)"
[[ "$tools" == *table-cli* && "$tools" != *$'\n'version* ]]
printf 'fresh-cli = "latest"\n' >> "$fixture/repo/mise/conf.d/nvim.toml"
for mode in mise-tools mise-binaries; do
    if output="$(inventory "$fixture/repo" "$mode" 2>&1)"; then
        echo "FAIL: duplicate mise tool accepted by $mode" >&2
        exit 1
    fi
    [[ "$output" == *"fresh-cli is declared more than once"* ]]
done
echo 'PASS: inventories follow manifests, conf.d, renamed commands and TOML tables; reject duplicates'
