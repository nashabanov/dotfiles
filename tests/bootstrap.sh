#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/scripts"
export BOOTSTRAP_FIXTURE="$fixture"

# Simulate the installer without accessing the network or real Homebrew.
cat > "$fixture/bin/curl" <<'MOCK'
#!/bin/bash
cat <<'INSTALL'
mkdir -p "$BOOTSTRAP_PREFIX/bin"
cp "$BOOTSTRAP_FIXTURE/brew" "$BOOTSTRAP_PREFIX/bin/brew"
chmod +x "$BOOTSTRAP_PREFIX/bin/brew"
INSTALL
MOCK
cat > "$fixture/brew" <<'MOCK'
#!/bin/bash
case "$1" in
    shellenv) printf 'export PATH="%s/bin:$PATH"\n' "$BOOTSTRAP_PREFIX" ;;
    install) [[ "$2" == mise ]]; touch "$BOOTSTRAP_FIXTURE/mise-installed" ;;
    *) exit 1 ;;
esac
MOCK
cat > "$fixture/bin/make" <<'MOCK'
#!/bin/bash
[[ "$1" == -C && "$2" == "$BOOTSTRAP_FIXTURE" && "$3" == bootstrap ]]
command -v brew >/dev/null
[[ -f "$BOOTSTRAP_FIXTURE/mise-installed" ]]
touch "$BOOTSTRAP_FIXTURE/bootstrapped"
MOCK
chmod +x "$fixture/bin/curl" "$fixture/bin/make"

# Substitute standard prefixes in a copy so the test stays fully isolated.
sed -e "s|/opt/homebrew|$fixture/arm|g" \
    -e "s|/usr/local|$fixture/intel|g" \
    "$ROOT/scripts/bootstrap.sh" > "$fixture/scripts/bootstrap.sh"
for architecture in arm intel; do
    export BOOTSTRAP_PREFIX="$fixture/$architecture"
    PATH="$fixture/bin:/usr/bin:/bin" /bin/bash "$fixture/scripts/bootstrap.sh" >/dev/null
    [[ -f "$fixture/bootstrapped" ]]
    rm -rf "$BOOTSTRAP_PREFIX"
    rm "$fixture/bootstrapped" "$fixture/mise-installed"
done

echo 'PASS: fresh bootstrap activates Homebrew on Apple Silicon and Intel'
