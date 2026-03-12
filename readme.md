# Positron PKGBUILD for Arch Linux

PKGBUILD that wraps the official Positron .deb package for Arch Linux.

## Installation

Clone the repository, fetch the latest release metadata, build, and install:

```bash
git clone https://github.com/mark-andrews/positron-ide-archlinux-installer.git
cd positron-ide-archlinux-installer
python3 fetch-latest-version.py
./update-pkgbuild.sh
makepkg -si
```

`fetch-latest-version.py` requires only the Python standard library (Python 3.10+).
It scrapes the Positron download page and writes the version, URL, and SHA-256 hash
into `positron-version.conf`.
`update-pkgbuild.sh` then downloads the `.deb`, verifies its hash, and patches `PKGBUILD`
and `.SRCINFO` accordingly.

## Updating to a New Version

```bash
python3 fetch-latest-version.py
./update-pkgbuild.sh
makepkg -si
```

To check whether an update is available without making any changes:

```bash
python3 fetch-latest-version.py --check
```

This exits with code 0 if already up to date, or 1 if a newer release is available,
making it suitable for use in scripts or cron jobs:

```bash
python3 fetch-latest-version.py --check || (./update-pkgbuild.sh && makepkg -si)
```

To preview what `fetch-latest-version.py` would write to `positron-version.conf`
without actually writing it:

```bash
python3 fetch-latest-version.py --dry-run
```

## Files

- `fetch-latest-version.py` — scrapes the Positron download page and updates `positron-version.conf`
- `positron-version.conf` — version, download URL, and SHA-256 hash for the current release
- `update-pkgbuild.sh` — downloads the `.deb`, verifies it, and updates `PKGBUILD` and `.SRCINFO`
- `PKGBUILD` — Arch Linux package build script
- `.SRCINFO` — generated package metadata (produced by `update-pkgbuild.sh`)
