# Positron PKGBUILD
Custom PKGBUILD for Positron IDE with integrity protection.

This PKGBUILD was created with assistance from GitHub Copilot using Claude 3.5 Sonnet.

## Files to commit:

This PKGBUILD was created to address file corruption issues with the `copilot-language-server` that occurred with existing AUR packages, causing GitHub Copilot to malfunction in Positron on Arch Linux.

### Key Features

- 🔒 **Dual integrity verification** of the critical `copilot-language-server` file
- 🛡️ **Build fails** if file corruption is detected at any point
- ⚡ **Optimized build** with disabled stripping and debug symbols for faster installation
- 📦 **Direct deb extraction** preserving all file permissions and attributes

## Prerequisites

1. **Download the Positron deb package** from [Posit's website](https://positron.posit.co/download.html)
2. Place the `Positron-2025.10.1-4-x64.deb` file in the same directory as this PKGBUILD

## Installation

```bash
# Clone this repository
git clone <your-repo-url>
cd positron-2025.10.1-4-x64-arch

# Download the Positron deb file (place it in this directory)
# Get it from: https://positron.posit.co/download.html

# Build and install
makepkg -si
```

## Integrity Verification

The PKGBUILD performs two SHA256 checks on the `copilot-language-server` file:
- **Expected hash:** `b6ef4e2f54af0a92128270582892c2cf6011a77ee00700be491ef340e9619a6c`
- **Build phase:** Verifies extracted file integrity
- **Package phase:** Verifies final installed file integrity

If either check fails, the build will abort with an error message.

## Version Updates

When Positron releases a new version:
1. Update the `pkgver` in PKGBUILD
2. Update the source filename to match the new deb file
3. Update the SHA256 hash of the deb file
4. Update the expected hash of `copilot-language-server` if it changes

## Troubleshooting

If the build fails with integrity check errors, this means:
- The deb file may be corrupted during download
- Positron changed their copilot implementation
- The extraction process is corrupting files

**This is exactly what this PKGBUILD is designed to catch and prevent!**

## Disclaimer

This PKGBUILD was created primarily for personal use to solve a specific issue with Positron on Arch Linux. While it works well for my setup and others are welcome to use it, please note:

- **Use at your own risk** - This is a personal project, not an official package
- **No warranties or guarantees** - I provide this as-is with no support obligations
- **Test first** - Consider testing in a VM or non-critical system before main installation
- **Community contribution** - Feel free to fork, modify, or contribute improvements

If you encounter issues, you're welcome to open an issue, but please understand this is a hobby project with no guaranteed response time or resolution.

## License

This PKGBUILD is provided as-is for the Arch Linux community. Positron itself is licensed by Posit Software, PBC.