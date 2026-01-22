#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Positron PKGBUILD Updater ===${NC}\n"

if [[ ! -f "positron-version.conf" ]]; then
    echo -e "${RED}Error: positron-version.conf not found${NC}"
    exit 1
fi

source positron-version.conf

VERSION="$POSITRON_VERSION"
DEB_URL="$POSITRON_DEB_URL"
DEB_SHA256="$POSITRON_DEB_SHA256"

if [[ -z "$VERSION" || -z "$DEB_URL" || -z "$DEB_SHA256" ]]; then
    echo -e "${RED}Error: Missing required variables in positron-version.conf${NC}"
    echo -e "Required: POSITRON_VERSION, POSITRON_DEB_URL, POSITRON_DEB_SHA256"
    exit 1
fi

DEB_FILENAME=$(basename "$DEB_URL")

echo -e "Configuration:"
echo -e "  Version:  ${YELLOW}${VERSION}${NC}"
echo -e "  Filename: ${YELLOW}${DEB_FILENAME}${NC}"
echo -e "  SHA-256:  ${YELLOW}${DEB_SHA256}${NC}\n"

if [[ -f "$DEB_FILENAME" ]]; then
    echo -e "Verifying existing ${DEB_FILENAME}..."
    EXISTING_SHA=$(sha256sum "$DEB_FILENAME" | cut -d' ' -f1)
    if [[ "$EXISTING_SHA" == "$DEB_SHA256" ]]; then
        echo -e "${GREEN}✓ Verified${NC}\n"
    else
        echo -e "${YELLOW}Hash mismatch, re-downloading...${NC}"
        rm "$DEB_FILENAME"
        curl -L -o "$DEB_FILENAME" "$DEB_URL"
    fi
else
    echo -e "Downloading ${DEB_FILENAME}..."
    curl -L -o "$DEB_FILENAME" "$DEB_URL"
fi

ACTUAL_SHA=$(sha256sum "$DEB_FILENAME" | cut -d' ' -f1)
if [[ "$ACTUAL_SHA" != "$DEB_SHA256" ]]; then
    echo -e "${RED}✗ SHA-256 mismatch${NC}"
    echo -e "  Expected: ${DEB_SHA256}"
    echo -e "  Got:      ${ACTUAL_SHA}"
    exit 1
fi
echo -e "${GREEN}✓ Download verified${NC}\n"

echo -e "Updating PKGBUILD..."
sed -i "s/^pkgver=.*/pkgver=${VERSION}/" PKGBUILD
sed -i "s/^source=.*$/source=(\"${DEB_FILENAME}\")/" PKGBUILD
sed -i "s/^sha256sums=.*$/sha256sums=('${DEB_SHA256}')/" PKGBUILD
sed -i "s/bsdtar -xf \"Positron-.*.deb\"/bsdtar -xf \"${DEB_FILENAME}\"/" PKGBUILD
echo -e "${GREEN}✓ PKGBUILD updated${NC}\n"

if command -v makepkg &> /dev/null; then
    echo -e "Generating .SRCINFO..."
    makepkg --printsrcinfo > .SRCINFO
    echo -e "${GREEN}✓ .SRCINFO generated${NC}\n"
fi

echo -e "${GREEN}=== Done ===${NC}"
echo -e "Next: ${YELLOW}makepkg -si${NC}"
