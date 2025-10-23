# Maintainer: Andrews
options=("!strip" "!debug")
pkgname=positron-bin
pkgver=2025.10.1.4
pkgrel=1
pkgdesc="A next-generation data science IDE"
arch=('x86_64')
url="https://www.posit.co/"
license=('custom')
depends=('ca-certificates' 'alsa-lib' 'at-spi2-atk' 'atk' 'at-spi2-core' 'glibc' 
         'cairo' 'libcups' 'curl' 'dbus' 'expat' 'mesa' 'glib2' 'gtk3' 'nspr' 
         'nss' 'pango' 'gcc-libs' 'systemd-libs' 'libx11' 'libxcb' 'libxcomposite' 
         'libxdamage' 'libxext' 'libxfixes' 'libxkbcommon' 'libxkbfile' 'libxrandr' 
         'xdg-utils')
optdepends=('vulkan-icd-loader: for vulkan support')
provides=('positron')
conflicts=('positron')
source=("Positron-2025.10.1-4-x64.deb")
sha256sums=('c6ee0320d2bdb7e93a064130c21f47fffa5d91b5ce87b0ba15259b00a39361c5')
noextract=("Positron-2025.10.1-4-x64.deb")

prepare() {
    # Extract the deb package
    bsdtar -xf "Positron-2025.10.1-4-x64.deb"
    bsdtar -xf data.tar.xz
}

build() {
    # Verify the critical copilot-language-server file integrity
    local copilot_file="usr/share/positron/resources/app/extensions/positron-assistant/resources/copilot/copilot-language-server"
    if [[ -f "$copilot_file" ]]; then
        local expected_hash="b6ef4e2f54af0a92128270582892c2cf6011a77ee00700be491ef340e9619a6c"
        local actual_hash=$(sha256sum "$copilot_file" | cut -d' ' -f1)
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            error "copilot-language-server file integrity check failed!"
            error "Expected: $expected_hash"
            error "Actual:   $actual_hash"
            return 1
        fi
        msg2 "copilot-language-server integrity verified: $actual_hash"
    else
        error "copilot-language-server file not found!"
        return 1
    fi
}

package() {
    # Copy all files to their destinations, preserving permissions
    cp -a usr/ "$pkgdir"/
    
    # Create the /usr/bin symlink that the postinst script would create
    install -d "$pkgdir/usr/bin"
    ln -s /usr/share/positron/bin/positron "$pkgdir/usr/bin/positron"
    
    # Ensure executable permissions on critical files
    chmod 755 "$pkgdir/usr/share/positron/positron"
    chmod 755 "$pkgdir/usr/share/positron/bin/positron"
    chmod 755 "$pkgdir/usr/share/positron/resources/app/extensions/positron-assistant/resources/copilot/copilot-language-server"
    
    # Verify the file integrity one more time in the final package
    local copilot_file="$pkgdir/usr/share/positron/resources/app/extensions/positron-assistant/resources/copilot/copilot-language-server"
    local expected_hash="b6ef4e2f54af0a92128270582892c2cf6011a77ee00700be491ef340e9619a6c"
    local actual_hash=$(sha256sum "$copilot_file" | cut -d' ' -f1)
    if [[ "$actual_hash" != "$expected_hash" ]]; then
        error "Final copilot-language-server file integrity check failed!"
        error "Expected: $expected_hash"
        error "Actual:   $actual_hash"
        return 1
    fi
    msg2 "Final copilot-language-server integrity verified: $actual_hash"
    
    # Install license (if it exists)
    if [[ -f "usr/share/positron/LICENSE.rtf" ]]; then
        install -Dm644 "usr/share/positron/LICENSE.rtf" \
            "$pkgdir/usr/share/licenses/$pkgname/LICENSE.rtf"
    fi
}