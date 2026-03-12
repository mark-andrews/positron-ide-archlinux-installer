# Maintainer: Andrews
options=("!strip" "!debug")
pkgname=positron-bin
pkgver=2026.03.0.212
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
source=("Positron-2026.03.0-212-x64.deb")
sha256sums=('dfbb96c74f407057caaec7da76ce04f35bc6d805f9ef91fb1a83f2e8079c89ff')

prepare() {
    bsdtar -xf "Positron-2026.03.0-212-x64.deb"
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
