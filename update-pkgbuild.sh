#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Positron PKGBUILD Auto-Updater ===${NC}\n"

# Check if config file exists
if [[ ! -f "positron-version.conf" ]]; then
    echo -e "${RED}Error: positron-version.conf not found!${NC}"
    exit 1
fi

# Load configuration
source positron-version.conf

# Use simpler variable names internally
VERSION="$POSITRON_VERSION"
DEB_URL="$POSITRON_DEB_URL"
DEB_SHA256="$POSITRON_DEB_SHA256"

# Validate configuration
if [[ -z "$VERSION" || -z "$DEB_URL" || -z "$DEB_SHA256" ]]; then
    echo -e "${RED}Error: Missing required variables in positron-version.conf${NC}"
    echo -e "Required: POSITRON_VERSION, POSITRON_DEB_URL, POSITRON_DEB_SHA256"
    exit 1
fi

if [[ "$DEB_URL" == "PLACEHOLDER_URL_NEEDS_TO_BE_UPDATED" ]]; then
    echo -e "${RED}Error: Please update POSITRON_DEB_URL in positron-version.conf${NC}"
    echo -e "Visit https://positron.posit.co/download.html to get the download URL"
    exit 1
fi

# Extract filename from URL
DEB_FILENAME=$(basename "$DEB_URL")

echo -e "Configuration loaded:"
echo -e "  Version:      ${YELLOW}${VERSION}${NC}"
echo -e "  DEB URL:      ${YELLOW}${DEB_URL}${NC}"
echo -e "  DEB Filename: ${YELLOW}${DEB_FILENAME}${NC}"
echo -e "  Expected SHA: ${YELLOW}${DEB_SHA256}${NC}\n"

# Download the deb file if it doesn't exist or is different
if [[ -f "$DEB_FILENAME" ]]; then
    echo -e "${YELLOW}$DEB_FILENAME already exists, verifying...${NC}"
    EXISTING_SHA=$(sha256sum "$DEB_FILENAME" | cut -d' ' -f1)
    if [[ "$EXISTING_SHA" == "$DEB_SHA256" ]]; then
        echo -e "${GREEN}✓ Existing file verified${NC}\n"
    else
        echo -e "${YELLOW}Hash mismatch, re-downloading...${NC}"
        rm "$DEB_FILENAME"
        echo -e "Downloading ${YELLOW}${DEB_FILENAME}${NC}..."
        curl -L -o "$DEB_FILENAME" "$DEB_URL"
    fi
else
    echo -e "Downloading ${YELLOW}${DEB_FILENAME}${NC}..."
    curl -L -o "$DEB_FILENAME" "$DEB_URL"
fi

# Verify downloaded file
echo -e "Verifying download..."
ACTUAL_SHA=$(sha256sum "$DEB_FILENAME" | cut -d' ' -f1)

if [[ "$ACTUAL_SHA" != "$DEB_SHA256" ]]; then
    echo -e "${RED}✗ SHA-256 mismatch!${NC}"
    echo -e "  Expected: ${DEB_SHA256}"
    echo -e "  Got:      ${ACTUAL_SHA}"
    exit 1
fi

echo -e "${GREEN}✓ Download verified${NC}\n"

# Extract and check copilot-language-server hash
echo -e "Extracting deb to check copilot-language-server..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

bsdtar -xf "$OLDPWD/$DEB_FILENAME" 2>/dev/null || tar -xf "$OLDPWD/$DEB_FILENAME"
bsdtar -xf data.tar.xz 2>/dev/null || tar -xf data.tar.xz

COPILOT_PATH="usr/share/positron/resources/app/extensions/positron-assistant/resources/copilot/copilot-language-server"

if [[ ! -f "$COPILOT_PATH" ]]; then
    echo -e "${RED}✗ copilot-language-server not found at expected path!${NC}"
    echo -e "  Path checked: ${COPILOT_PATH}"
    cd "$OLDPWD"
    rm -rf "$TEMP_DIR"
    exit 1
fi

COPILOT_SHA=$(sha256sum "$COPILOT_PATH" | cut -d' ' -f1)
echo -e "${GREEN}✓ Found copilot-language-server${NC}"
echo -e "  SHA-256: ${YELLOW}${COPILOT_SHA}${NC}\n"

cd "$OLDPWD"
rm -rf "$TEMP_DIR"

# Update PKGBUILD
echo -e "Updating PKGBUILD..."

# Backup original
cp PKGBUILD PKGBUILD.backup

# Update pkgver (line 4)
sed -i "s/^pkgver=.*/pkgver=${VERSION}/" PKGBUILD

# Update source filename (line 18)
sed -i "s/^source=.*$/source=(\"${DEB_FILENAME}\")/" PKGBUILD

# Update sha256sums (line 19)
sed -i "s/^sha256sums=.*$/sha256sums=('${DEB_SHA256}')/" PKGBUILD

# Update prepare() function - filename in bsdtar
sed -i "s/bsdtar -xf \"Positron-.*.deb\"/bsdtar -xf \"${DEB_FILENAME}\"/" PKGBUILD

# Update expected_hash in build() function
sed -i "/local expected_hash=/s/=\"[^\"]*\"/=\"${COPILOT_SHA}\"/" PKGBUILD

# Update expected_hash in package() function (second occurrence)
awk -v new_hash="$COPILOT_SHA" '
/package\(\)/ {in_package=1}
in_package && /local expected_hash=/ {
    sub(/="[^"]*"/, "=\"" new_hash "\"")
}
{print}
' PKGBUILD > PKGBUILD.tmp && mv PKGBUILD.tmp PKGBUILD

echo -e "${GREEN}✓ PKGBUILD updated${NC}\n"

# Show diff
echo -e "${YELLOW}=== Changes made to PKGBUILD ===${NC}"
diff -u PKGBUILD.backup PKGBUILD || true
echo ""

# Generate .SRCINFO
if command -v makepkg &> /dev/null; then
    echo -e "Generating .SRCINFO..."
    makepkg --printsrcinfo > .SRCINFO
    echo -e "${GREEN}✓ .SRCINFO generated${NC}\n"
else
    echo -e "${YELLOW}⚠ makepkg not found, skipping .SRCINFO generation${NC}\n"
fi

# Summary
echo -e "${GREEN}=== Update Complete ===${NC}"
echo -e "Summary of changes:"
echo -e "  • Version:                ${YELLOW}${VERSION}${NC}"
echo -e "  • DEB file:               ${YELLOW}${DEB_FILENAME}${NC}"
echo -e "  • DEB SHA-256:            ${YELLOW}${DEB_SHA256:0:16}...${NC}"
echo -e "  • Copilot server SHA-256: ${YELLOW}${COPILOT_SHA:0:16}...${NC}"
echo -e "\nNext steps:"
echo -e "  1. Review changes: ${YELLOW}diff -u PKGBUILD.backup PKGBUILD${NC}"
echo -e "  2. Test build:     ${YELLOW}makepkg -si${NC}"
echo -e "  3. Commit changes: ${YELLOW}git add -A && git commit -m 'Update to version ${VERSION}'${NC}"
echo -e "\nBackup saved as: ${YELLOW}PKGBUILD.backup${NC}"
