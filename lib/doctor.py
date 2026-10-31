"""Read-only environment diagnostics: no installs or configuration startup."""

import os
import shutil
import subprocess
import sys
from pathlib import Path

from inventory import brew_inventory, mise_inventory


class Doctor:
    def __init__(self, root: Path):
        self.root = root
        self.home = Path(os.environ["HOME"])
        self.counts: dict[str, int] = dict.fromkeys(("OK", "FAIL", "WARN"), 0)
        self.color = (
            "NO_COLOR" not in os.environ
            and os.environ.get("FORCE_COLOR") != "0"
            and (
                bool(os.environ.get("FORCE_COLOR"))
                or (sys.stdout.isatty() and os.environ.get("TERM", "dumb") != "dumb")
            )
        )

    def paint(self, text: str, code: str) -> str:
        return f"\033[{code}m{text}\033[0m" if self.color else text

    def report(self, status: str, name: str | Path, detail: str):
        self.counts[status] += 1
        label = self.paint(
            f"[{status:<4}]", {"OK": "32", "FAIL": "31", "WARN": "33"}[status]
        )
        print(f"  {label} {name!s:<32} {detail}")

    def section(self, title: str):
        print("\n" + self.paint(title, "1;36"))

    def check_binary(self, binary: str, hint: str):
        location = shutil.which(binary)
        self.report(
            "OK" if location else "FAIL",
            binary,
            location or f"missing from PATH; {hint}",
        )

    def inventory(self, mode: str, label: str) -> list[str]:
        try:
            reader = mise_inventory if mode.startswith("mise-") else brew_inventory
            return reader(self.root, mode)
        except (OSError, TypeError, ValueError) as error:
            self.report("FAIL", label, f"could not read inventory: {error}")
            return []

    @staticmethod
    def run(*args: str, env: dict[str, str] | None = None) -> tuple[bool, str]:
        try:
            result = subprocess.run(
                args,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                check=False,
                env=env,
            )
            return result.returncode == 0, result.stdout.rstrip()
        except OSError as error:
            return False, str(error)

    def binaries(self):
        self.section("System and Homebrew binaries")
        for binary in ("bash", "zsh", "git", "make", "curl", "cc"):
            self.check_binary(binary, "install system / Xcode command line tools")
        self.check_binary("brew", "install Homebrew")
        for binary in self.inventory("brew-binaries", "Brewfile inventory"):
            self.check_binary(binary, "run make brew-install")
        for app in self.inventory("brew-apps", "Application inventory"):
            binary = Path(app).name
            if shutil.which(binary):
                self.check_binary(binary, "run make brew-install")
                continue
            for base in (Path("/Applications"), self.home / "Applications"):
                path = base / app
                if path.is_file() and os.access(path, os.X_OK):
                    self.report("OK", binary, str(path))
                    break
            else:
                self.report(
                    "FAIL", binary, "application missing; run make brew-install"
                )
        self.section("mise binaries: CLI, formatters, linters and language servers")
        for binary in self.inventory("mise-binaries", "mise inventory"):
            self.check_binary(binary, "run make tools-install; check mise activation")
        if shutil.which("fzf"):
            ok, _ = self.run("fzf", "--zsh")
            self.report(
                "OK" if ok else "FAIL",
                "FZF shell integration",
                "fzf --zsh available"
                if ok
                else "fzf --zsh failed; run make tools-install",
            )

    def links(self):
        self.section("Managed symlinks")
        terminal = os.environ["DOTFILES_TERMINAL"]
        try:
            lines = (self.root / "symlinks.conf").read_text().splitlines()
            for line in lines:
                if not line or line.startswith("#"):
                    continue
                source_name, target_name, _ = line.split("|", 2)
                owner = source_name.split("/", 1)[0]
                if owner in ("wezterm", "ghostty") and terminal not in ("both", owner):
                    continue
                source, target = self.root / source_name, self.home / target_name
                status = "FAIL"
                if not source.exists():
                    detail = f"repository source missing: {source}"
                elif not target.is_symlink():
                    detail = (
                        "exists but is not a symlink; review before make links"
                        if target.exists()
                        else "missing; run make links"
                    )
                elif not target.exists():
                    detail = f"broken link -> {target.readlink()}; run make links"
                elif target.samefile(source):
                    status, detail = "OK", f"-> {target.readlink()}"
                else:
                    detail = f"wrong destination -> {target.readlink()}; run make links"
                self.report(status, target, detail)
        except (OSError, ValueError) as error:
            self.report("FAIL", "Symlink inventory", str(error))

    def homebrew(self):
        self.section("Homebrew packages and Zsh integrations")
        if not shutil.which("brew"):
            self.report("WARN", "Homebrew integrations", "skipped: brew unavailable")
            return
        ok, output = self.run(
            "brew",
            "bundle",
            "check",
            "--no-upgrade",
            f"--file={self.root / 'Brewfile'}",
            env={**os.environ, "HOMEBREW_NO_AUTO_UPDATE": "1"},
        )
        self.report(
            "OK" if ok else "FAIL",
            "Brewfile",
            "all dependencies installed (respecting HOMEBREW_BUNDLE_CASK_SKIP)"
            if ok
            else "missing dependencies; run make brew-install",
        )
        if not ok:
            print(output)
        ok, prefix = self.run("brew", "--prefix")
        if not ok:
            self.report("FAIL", "Homebrew prefix", "brew --prefix failed")
            return
        for name in self.inventory("brew-files", "Brewfile files"):
            path = Path(prefix) / name
            readable = os.access(path, os.R_OK)
            self.report(
                "OK" if readable else "FAIL",
                name,
                str(path)
                if readable
                else "missing or unreadable; run make brew-install",
            )

    def syntax(self):
        self.section("Shell configuration syntax")
        files = sorted((self.root / "lib").glob("*.sh"))
        files += sorted((self.root / "tests").glob("*.sh"))
        for path in files:
            ok, output = self.run("bash", "-n", str(path))
            self.report(
                "OK" if ok else "FAIL",
                path.relative_to(self.root),
                "bash syntax valid" if ok else output,
            )
        if not shutil.which("zsh"):
            self.report("WARN", "Zsh syntax", "skipped: zsh unavailable")
            return
        for path in [
            self.root / "zsh/.zshrc",
            *sorted((self.root / "zsh").glob("*.zsh")),
        ]:
            ok, output = self.run("zsh", "-n", str(path))
            self.report(
                "OK" if ok else "FAIL",
                path.relative_to(self.root),
                "zsh syntax valid" if ok else output,
            )

    def environment(self):
        self.section("Neovim and shell environment")
        data = Path(os.environ.get("XDG_DATA_HOME") or self.home / ".local/share")
        lazy = data / "nvim/lazy/lazy.nvim"
        readable = os.access(lazy / "lua/lazy/init.lua", os.R_OK)
        self.report(
            "OK" if readable else "WARN",
            "lazy.nvim",
            str(lazy)
            if readable
            else "not bootstrapped; launch nvim to install plugins",
        )
        shell = os.environ.get("SHELL", "")
        self.report(
            "OK" if shell.endswith("/zsh") else "WARN",
            "Login shell",
            shell
            if shell.endswith("/zsh")
            else f"{shell or 'unset'}; configuration targets zsh",
        )
        for variable, expected, hint in (
            ("ZDOTDIR", self.home, "zsh may not load the managed ~/.zshrc"),
            (
                "XDG_CONFIG_HOME",
                self.home / ".config",
                "installer links configurations under ~/.config",
            ),
        ):
            value = os.environ.get(variable)
            if value and value != str(expected):
                self.report("WARN", variable, f"{value}; {hint}")

    def check(self) -> int:
        print(f"Dotfiles doctor\nRepository: {self.root}\nHome: {self.home}")
        self.binaries()
        self.links()
        self.homebrew()
        self.syntax()
        self.environment()
        summary = ", ".join(
            self.paint(f"{self.counts[status]} {label}", code)
            for status, label, code in (
                ("OK", "passed", "32"),
                ("FAIL", "failed", "31"),
                ("WARN", "warnings", "33"),
            )
        )
        print(f"\nSummary: {summary}")
        return int(self.counts["FAIL"] > 0)


if __name__ == "__main__":
    sys.exit(Doctor(Path(sys.argv[1])).check())
