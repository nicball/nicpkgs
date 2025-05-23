{ stdenv, fetchzip, autoconf, automake, libtool, pkg-config, nautilus, gtk2, glib }:

stdenv.mkDerivation {
  pname = "nutstore-nautilus";
  version = "6.3.6";
  src = fetchzip {
    url = "https://www.jianguoyun.com/static/exe/installer/nutstore_linux_src_installer.tar.gz";
    sha256 = "sha256-G74Q51jCkZvNXX26aaSEzbQm3L0cGkiCfrb14JaMF/4=";
  };
  nativeBuildInputs = [ autoconf automake libtool pkg-config ];
  buildInputs = [ nautilus.dev gtk2 glib ];
  preConfigure = "source ./update-toolchain.sh; set +u";
  configureFlags = [ "--with-nautilus-extension-dir=$(out)/lib/nautilus/extension-4" ];
  NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion -Wno-error=incompatible-pointer-types";
}
