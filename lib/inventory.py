"""Read package inventories without activating configs or installing tools."""

import argparse
import re
import sys
import tomllib
from pathlib import Path

MODES = ("mise-tools", "mise-binaries", "brew-binaries", "brew-files", "brew-apps")
MISE_DECLARATION = re.compile(r'^\s*("[^"]+"|[\w-]+)\s*=.*?# doctor:\s*(.+)$')
BREW_DECLARATION = re.compile(r'^\s*(brew|cask)\s+"([^"]+)"(.*)$')


def mise_config_paths(root: Path) -> list[Path]:
    """Return mise config files managed by this repository."""
    base = root / "mise"
    paths = [base / "config.toml"]
    conf_d = base / "conf.d"

    if conf_d.is_dir():
        paths.extend(
            path
            for path in sorted(conf_d.glob("*.toml"))
            if not path.name.startswith(".")
        )

    return paths


def mise_inventory(root: Path, mode: str) -> list[str]:
    """Read TOML tool names and command overrides from adjacent comments."""
    tools: list[str] = []
    seen_tools: set[str] = set()
    overrides: dict[str, list[str]] = {}

    for path in mise_config_paths(root):
        text = path.read_text(encoding="utf-8")
        data = tomllib.loads(text)

        declared_tools = data.get("tools", {})
        if not isinstance(declared_tools, dict):
            raise TypeError(f"{path.relative_to(root)}: tools must be a table")

        for tool in declared_tools:
            if tool in seen_tools:
                raise ValueError(
                    f"{tool} is declared more than once in mise configuration"
                )

            seen_tools.add(tool)
            tools.append(tool)

        for line in text.splitlines():
            match = MISE_DECLARATION.match(line)
            if match:
                tool = match[1].strip('"')
                overrides[tool] = match[2].split()

    if mode == "mise-tools":
        return tools

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
