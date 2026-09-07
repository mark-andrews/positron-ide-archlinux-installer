# Maintainer: Andrews
options=("!strip" "!debug")
pkgname=positron-bin
pkgver=2026.09.1.2
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
source=("Positron-2026.09.1-2-x64.deb")
sha256sums=('21fa959af68847dbb0c13f3d3ad84665ff156e0af20a80469c4a1d5db018209b')

prepare() {
    bsdtar -xf "Positron-2026.09.1-2-x64.deb"
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
