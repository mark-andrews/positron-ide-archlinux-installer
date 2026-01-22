# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Arch Linux PKGBUILD for Positron IDE (a data science IDE from Posit). Wraps the official .deb package.

## Repository Structure

- `PKGBUILD` - Arch Linux package build script
- `.SRCINFO` - Generated package metadata
- `positron-version.conf` - Version, download URL, and SHA-256 hash
- `update-pkgbuild.sh` - Downloads deb and updates PKGBUILD

## Commands

Update to a new version (after editing `positron-version.conf`):
```bash
./update-pkgbuild.sh
```

Build and install:
```bash
makepkg -si
```

## Update Workflow

1. Edit `positron-version.conf` with values from https://positron.posit.co/download.html
2. Run `./update-pkgbuild.sh`
3. Test with `makepkg -si`
