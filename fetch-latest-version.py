#!/usr/bin/env python3
"""Fetch latest Positron x64 .deb version info and update positron-version.conf."""

import argparse
import re
import sys
import urllib.request
from pathlib import Path

DOWNLOAD_URL = "https://positron.posit.co/download.html"
CONF_FILE = Path(__file__).parent / "positron-version.conf"


def fetch_page(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8")


def extract_x64_deb_info(html: str) -> tuple[str, str, str]:
    """Return (version, deb_url, sha256) for the x64 Ubuntu .deb package."""
    pattern = (
        r"Debian-based Linux x64.*?"
        r'href="(https://cdn\.posit\.co/positron/releases/deb/x86_64/'
        r"Positron-([0-9]+\.[0-9]+\.[0-9]+-[0-9]+)-x64\.deb)\".*?"
        r"copyChecksum\('([a-f0-9]{64})'"
    )
    m = re.search(pattern, html, re.DOTALL)
    if not m:
        raise ValueError("Could not find x64 .deb entry on download page.")
    deb_url = m.group(1)
    raw_version = m.group(2)          # e.g. 2026.03.0-212
    sha256 = m.group(3)
    version = raw_version.replace("-", ".", 1)  # e.g. 2026.03.0.212
    return version, deb_url, sha256


def update_conf(version: str, deb_url: str, sha256: str) -> None:
    content = (
        "# Positron Version Configuration\n"
        "# Get values from https://positron.posit.co/download.html\n"
        "\n"
        f'POSITRON_VERSION="{version}"\n'
        f'POSITRON_DEB_URL="{deb_url}"\n'
        f'POSITRON_DEB_SHA256="{sha256}"\n'
    )
    CONF_FILE.write_text(content)


def current_version() -> str | None:
    """Return the version string in positron-version.conf, or None if absent."""
    if not CONF_FILE.exists():
        return None
    m = re.search(r'^POSITRON_VERSION="([^"]+)"', CONF_FILE.read_text(), re.MULTILINE)
    return m.group(1) if m else None


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch the latest Positron release and update positron-version.conf.",
    )
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument(
        "--check",
        action="store_true",
        help=(
            "Check whether an update is available without writing anything. "
            "Exits 0 if already up to date, 1 if an update is available."
        ),
    )
    mode.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be written to positron-version.conf without writing it.",
    )
    args = parser.parse_args()

    print(f"Fetching {DOWNLOAD_URL} ...")
    html = fetch_page(DOWNLOAD_URL)
    version, deb_url, sha256 = extract_x64_deb_info(html)
    installed = current_version()

    if args.check:
        if installed == version:
            print(f"Up to date ({version}).")
            sys.exit(0)
        else:
            print(f"Update available: {installed} -> {version}")
            sys.exit(1)

    print(f"Version : {version}")
    print(f"URL     : {deb_url}")
    print(f"SHA-256 : {sha256}")

    if args.dry_run:
        print("\n-- dry run: positron-version.conf would be written as --")
        print(f'POSITRON_VERSION="{version}"')
        print(f'POSITRON_DEB_URL="{deb_url}"')
        print(f'POSITRON_DEB_SHA256="{sha256}"')
        return

    if installed == version:
        print("\npositron-version.conf is already at this version. No changes made.")
        sys.exit(0)

    update_conf(version, deb_url, sha256)
    print(f"\nUpdated {CONF_FILE}")
    print("Run ./update-pkgbuild.sh to proceed.")


if __name__ == "__main__":
    main()
