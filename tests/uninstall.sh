#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/home/.cache/nvim" "$fixture/home/.local/share/nvim"
export CLEANUP_LOG="$fixture/commands"
cat > "$fixture/bin/brew" <<'STUB'
#!/usr/bin/env bash
case "$*" in
    'list --formula') printf 'git\nmise\nuv\nunrelated\n' ;;
    'list --cask') printf 'wezterm\norbstack\nunrelated-app\n' ;;
    'bundle list --formula '*) printf 'git\nmise\nuv\n' ;;
    'bundle list --cask '*) printf 'wezterm\norbstack\n' ;;
    uninstall*) printf 'brew %s\n' "$*" >> "$CLEANUP_LOG"; [[ "${FAIL_BREW:-0}" != 1 ]] ;;
    *) exit 2 ;;
esac
STUB
cat > "$fixture/bin/mise" <<'STUB'
#!/usr/bin/env bash
printf 'mise %s\n' "$*" >> "$CLEANUP_LOG"
[[ "${FAIL_MISE:-0}" != 1 ]]
STUB
chmod +x "$fixture/bin/brew" "$fixture/bin/mise"
export PATH="$fixture/bin:$PATH"
export HOME="$fixture/home"
unset XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
bash "$ROOT/symlinks.sh" >/dev/null
printf 'keep\n' > "$HOME/.local/share/nvim/undo"
bash "$ROOT/uninstall.sh" --dry-run --purge-data >/dev/null
[[ ! -e "$CLEANUP_LOG" && -L "$HOME/.zshrc" && -e "$HOME/.local/share/nvim/undo" ]]
printf 'n\n' | bash "$ROOT/uninstall.sh" >/dev/null
[[ ! -e "$CLEANUP_LOG" && -L "$HOME/.zshrc" ]]
bash "$ROOT/uninstall.sh" --yes >/dev/null
[[ ! -L "$HOME/.config/mise/config.toml" && ! -L "$HOME/.zshrc" ]]
[[ ! -d "$HOME/.cache/nvim" && -e "$HOME/.local/share/nvim/undo" ]]
rg -q 'uninstall --all .*go.*node.*python.*rust' "$CLEANUP_LOG"
rg -q 'brew uninstall --formula git mise uv' "$CLEANUP_LOG"
if rg -q 'unrelated|--zap|--ignore-dependencies' "$CLEANUP_LOG"; then exit 1; fi
[[ "$(head -1 "$CLEANUP_LOG")" == mise* ]]
bash "$ROOT/symlinks.sh" >/dev/null
bash "$ROOT/uninstall.sh" --yes --purge-data >/dev/null
[[ ! -d "$HOME/.local/share/nvim" ]]
rg -q 'brew uninstall --cask --zap wezterm orbstack' "$CLEANUP_LOG"
mkdir -p "$HOME/.local/share/nvim"
printf 'recover\n' > "$HOME/.local/share/nvim/undo"
bash "$ROOT/symlinks.sh" >/dev/null
: > "$CLEANUP_LOG"
if FAIL_BREW=1 bash "$ROOT/uninstall.sh" --yes --purge-data >/dev/null 2>&1; then exit 1; fi
[[ -e "$HOME/.local/share/nvim/undo" && -L "$HOME/.zshrc" ]]
if rg -q 'brew uninstall --formula' "$CLEANUP_LOG"; then exit 1; fi
: > "$CLEANUP_LOG"
if FAIL_MISE=1 bash "$ROOT/uninstall.sh" --yes --purge-data >/dev/null 2>&1; then exit 1; fi
[[ -e "$HOME/.local/share/nvim/undo" && -L "$HOME/.config/mise/config.toml" ]]
if rg -q '^brew ' "$CLEANUP_LOG"; then exit 1; fi
# Broken managed links are removed even if their source no longer exists.
mkdir "$fixture/orphan-repo"
cp "$ROOT/uninstall.sh" "$ROOT/symlinks.conf" "$fixture/orphan-repo/"
cp -R "$ROOT/lib" "$fixture/orphan-repo/"
rm "$HOME/.config/nvim"
ln -s "$fixture/orphan-repo/nvim" "$HOME/.config/nvim"
bash "$fixture/orphan-repo/uninstall.sh" --yes --links-only >/dev/null
[[ ! -L "$HOME/.config/nvim" ]]
# A cleanup directory must never enclose the repository or HOME, even via aliases.
safety="$fixture/safety/nvim/repo"
mkdir -p "$safety"
cp "$ROOT/uninstall.sh" "$ROOT/symlinks.conf" "$ROOT/Brewfile" "$safety/"
cp -R "$ROOT/lib" "$ROOT/mise" "$safety/"
: > "$CLEANUP_LOG"
if XDG_DATA_HOME="$fixture/safety" bash "$safety/uninstall.sh" --yes --purge-data >/dev/null 2>&1; then exit 1; fi
[[ -e "$safety/uninstall.sh" && ! -s "$CLEANUP_LOG" ]]
mkdir "$fixture/safety/nvim/user-home"
if HOME="$fixture/safety/nvim/user-home" XDG_DATA_HOME="$fixture/safety" bash "$ROOT/uninstall.sh" --yes --purge-data >/dev/null 2>&1; then exit 1; fi
[[ -d "$fixture/safety/nvim/user-home" && ! -s "$CLEANUP_LOG" ]]
ln -s "$fixture/safety" "$fixture/xdg-alias"
if XDG_DATA_HOME="$fixture/xdg-alias" bash "$safety/uninstall.sh" --yes --purge-data >/dev/null 2>&1; then exit 1; fi
[[ -e "$safety/uninstall.sh" && ! -s "$CLEANUP_LOG" ]]
echo 'PASS: uninstall stops on failures and protects repository/HOME ancestors'

