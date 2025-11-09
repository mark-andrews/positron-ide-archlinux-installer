# Positron PKGBUILD for Arch Linux

Custom PKGBUILD that prevents `copilot-language-server` corruption issues found in other AUR packages.

## Installation

```bash
git clone <your-repo-url>
cd positron-ide-archlinux-installer
./update-pkgbuild.sh  # Downloads and updates to current version
makepkg -si
```

## Updating to New Version

When Positron releases a new version:

1. Visit https://positron.posit.co/download.html and get:
   - Version number
   - Download URL (right-click download button → copy link)
   - SHA-256 hash

2. Edit `positron-version.conf`:
   ```bash
   POSITRON_VERSION="2025.XX.X.X"
   POSITRON_DEB_URL="https://..."
   POSITRON_DEB_SHA256="abc123..."
   ```

3. Run update script:
   ```bash
   ./update-pkgbuild.sh
   makepkg -si
   ```

The script automatically downloads the deb, verifies integrity, extracts the copilot-language-server hash, and updates PKGBUILD.

## How It Works

- Downloads official Positron `.deb` from Posit
- Performs dual SHA-256 verification of `copilot-language-server` during build and package phases
- Build fails if corruption detected
- Uses `!strip` and `!debug` options to prevent binary corruption

## Troubleshooting

**Build fails with integrity error**: This is intentional - the file is corrupted. Re-download or check if Positron changed their structure.

**Script can't download**: Check the URL in `positron-version.conf` is correct.

## License

PKGBUILD provided as-is for the Arch Linux community. Use at your own risk.