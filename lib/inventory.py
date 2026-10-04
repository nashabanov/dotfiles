"""Read package inventories without activating configs or installing tools."""

import argparse
import re
import sys
import tomllib
from pathlib import Path

MODES = ("mise-tools", "mise-binaries", "brew-binaries", "brew-files", "brew-apps")
MISE_DECLARATION = re.compile(r'^\s*("[^"]+"|[\w-]+)\s*=.*?# doctor:\s*(.+)$')
BREW_DECLARATION = re.compile(r'^\s*(brew|cask)\s+"([^"]+)"(.*)$')


def mise_inventory(root: Path, mode: str) -> list[str]:
    """Read TOML tool names and command overrides from adjacent comments."""
    text = (root / "mise/config.toml").read_text(encoding="utf-8")
    tools = tomllib.loads(text).get("tools", {})
    if not isinstance(tools, dict):
        raise TypeError("mise/config.toml: tools must be a table")
    if mode == "mise-tools":
        return list(tools)

    overrides: dict[str, list[str]] = {}
    for line in text.splitlines():
        match = MISE_DECLARATION.match(line)
        if match:
            overrides[match[1].strip('"')] = match[2].split()

    binaries: list[str] = []
    for tool in tools:
        commands = overrides.get(tool)
        if commands is None:
            if ":" in tool:
                raise ValueError(
                    f"Add # doctor: <commands> to the declaration of {tool}"
                )
            commands = [tool]
        binaries.extend(command for command in commands if command != "-")
    return binaries


def brew_inventory(root: Path, mode: str) -> list[str]:
    """Read the Brewfile's package declarations and doctor annotations."""
    entries: list[str] = []
    text = (root / "Brewfile").read_text(encoding="utf-8")
    for line in text.splitlines():
        declaration = BREW_DECLARATION.match(line)
        if declaration is None:
            continue
        kind, package, suffix = declaration.groups()
        files = re.search(r"# doctor-file:\s*(.+)", suffix)
        commands = re.search(r"# doctor:\s*(.+)", suffix)
        apps = re.search(r"# doctor-app:\s*(.+)", suffix)
        if mode == "brew-apps":
            if apps:
                entries.append(apps[1])
        elif mode == "brew-files":
            if files:
                entries.extend(files[1].split())
        elif commands:
            entries.extend(command for command in commands[1].split() if command != "-")
        elif kind == "brew" and files is None:
            entries.append(package.rsplit("/", 1)[-1])
    return entries


def main() -> int:
    """Validate CLI arguments and print a complete inventory or a concise error."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="Dotfiles repository directory")
    parser.add_argument("mode", choices=MODES)
    args = parser.parse_args()

    try:
        if args.mode.startswith("mise-"):
            entries = mise_inventory(args.root, args.mode)
        else:
            entries = brew_inventory(args.root, args.mode)
    except (OSError, TypeError, ValueError) as error:
        print(f"Inventory error: {error}", file=sys.stderr)
        return 1

    for entry in entries:
        print(entry)
    return 0


if __name__ == "__main__":
    sys.exit(main())
