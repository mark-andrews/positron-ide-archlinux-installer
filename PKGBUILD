# Maintainer: Andrews
options=("!strip" "!debug")
pkgname=positron-bin
pkgver=2026.06.0.211
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
source=("Positron-2026.06.0-211-x64.deb")
sha256sums=('62f9f07954ca02fc594d1e7f158d555add371b1e0b15ad9f68bf99d00602b696')

prepare() {
    bsdtar -xf "Positron-2026.06.0-211-x64.deb"
    bsdtar -xf data.tar.xz
}

package() {
    cp -a usr/ "$pkgdir"/

    install -d "$pkgdir/usr/bin"
    ln -s /usr/share/positron/bin/positron "$pkgdir/usr/bin/positron"

    chmod 755 "$pkgdir/usr/share/positron/positron"
    chmod 755 "$pkgdir/usr/share/positron/bin/positron"

    if [[ -f "usr/share/positron/LICENSE.rtf" ]]; then
        install -Dm644 "usr/share/positron/LICENSE.rtf" \
            "$pkgdir/usr/share/licenses/$pkgname/LICENSE.rtf"
    fi
}
