# Positron PKGBUILD for Arch Linux

PKGBUILD that wraps the official Positron .deb package for Arch Linux.

## Installation

```bash
git clone https://github.com/mark-andrews/positron-ide-archlinux-installer.git
cd positron-ide-archlinux-installer
./update-pkgbuild.sh
makepkg -si
```

## Updating to New Version

1. Visit https://positron.posit.co/download.html and get the version number, download URL, and SHA-256 hash
2. Edit `positron-version.conf` with the new values
3. Run `./update-pkgbuild.sh && makepkg -si`
