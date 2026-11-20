#!/usr/bin/env python3
"""Fetch latest Positron x64 .deb version info and update positron-version.conf.

Posit publishes no machine-readable release feed for Positron, so this
script reads the human-facing download page and pulls three facts out of
its HTML: the release version, the URL of the x64 Debian package, and that
package's SHA-256 checksum. It then writes them into positron-version.conf,
which update-pkgbuild.sh reads in the next step of the update workflow.

Because it scrapes HTML, the script depends on the layout of the download
page. If Posit redesigns that page, extract_x64_deb_info() is the function
that will stop working and need its pattern revised.
"""

import argparse
import re
import sys
import urllib.request
from pathlib import Path

DOWNLOAD_URL = "https://positron.posit.co/download.html"
CONF_FILE = Path(__file__).parent / "positron-version.conf"


def fetch_page(url: str) -> str:
    """Download a web page and return its HTML as a string.

    Uses only the standard library (urllib), so no third-party packages
    are needed. The request sends a browser-like User-Agent header because
    some web servers and CDNs refuse or alter responses to Python's default
    User-Agent. The request gives up after 30 seconds, and any network or
    HTTP error is raised as an exception rather than handled here, so a
    failed download stops the script with a traceback.
    """
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return resp.read().decode("utf-8")


def extract_x64_deb_info(html: str) -> tuple[str, str, str]:
    """Return (version, deb_url, sha256) for the x64 Ubuntu .deb package.

    The download page lists several builds (macOS, Windows, Linux on x64
    and ARM, .deb and .rpm). This function finds the x64 .deb entry with a
    single regular expression that matches three things in sequence:

    1. The text "Debian-based Linux x64", which labels the right section.
    2. The first link after it to a file of the form
       Positron-<version>-x64.deb on Posit's CDN. Two groups are captured
       here, the full URL and the version embedded in the filename.
    3. The first call to copyChecksum('<64 hex digits>') after that link.
       This is the JavaScript the page uses for its "copy checksum"
       button, and its argument is the package's SHA-256 hash.

    The ".*?" between the parts is a non-greedy wildcard, so each part
    matches the nearest following occurrence rather than one further down
    the page. re.DOTALL lets the wildcard cross line breaks in the HTML.

    The version in the filename has the form 2026.03.0-212. Arch package
    versions may not contain a hyphen, so the first hyphen is replaced
    with a dot to give 2026.03.0.212.

    Raises ValueError if the pattern is not found, which most likely means
    the page layout has changed.
    """
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
    """Overwrite positron-version.conf with the given release details.

    The file is written in shell variable syntax (NAME="value") so that
    update-pkgbuild.sh can load it with the shell's source command. The
    whole file is regenerated each time rather than edited in place, so
    any manual changes to it are lost.
    """
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
    """Return the version string in positron-version.conf, or None if absent.

    Reads the existing config file and looks for the line beginning
    POSITRON_VERSION=". re.MULTILINE makes "^" match at the start of each
    line, not only at the start of the file. The value between the quotes
    is returned. None is returned if the file does not exist or contains
    no such line, which the caller treats as "no version recorded".
    """
    if not CONF_FILE.exists():
        return None
    m = re.search(r'^POSITRON_VERSION="([^"]+)"', CONF_FILE.read_text(), re.MULTILINE)
    return m.group(1) if m else None


def main() -> None:
    """Parse command-line options, fetch the latest release, and act on it.

    The steps are always the same up to a point. The download page is
    fetched, the latest x64 .deb details are extracted, and the version
    already recorded in positron-version.conf is read. What happens next
    depends on the option given.

    With --check, the two versions are compared and the script exits with
    status 0 if they match and 1 if they differ. Nothing is written. The
    exit status is the point of this mode, since it lets a shell command
    such as "fetch-latest-version.py --check || ..." run an update only
    when one is available.

    With --dry-run, the new details are printed in the form they would
    take in the config file, and nothing is written.

    With no option, the config file is rewritten if the latest version
    differs from the recorded one, and left alone if it is the same.

    --check and --dry-run are declared mutually exclusive, so argparse
    rejects a command that gives both.
    """
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
