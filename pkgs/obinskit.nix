{ lib, stdenv, fetchzip
, makeWrapper , wrapGAppsHook3, autoPatchelfHook
, nss, nspr, alsa-lib, libdrm, mesa, systemd, cairo, pango, glib
, libxkbcommon, libxt, libxtst }:

stdenv.mkDerivation {
  pname = "obinskit";
  version = "1.2.11";
  src = fetchzip {
    url = "https://www.hexcore.xyz/occ/linux/tar/ObinsKit_1.2.11_x64.tar.gz";
    sha256 = "sha256-+OmPh9/PpEsC2beJx9fHGRp2ijk8mUrqb47+Z6FoIZc=";
  };
  nativeBuildInputs = [ makeWrapper wrapGAppsHook3 autoPatchelfHook ];
  buildInputs = [ nss nspr alsa-lib libdrm mesa pango cairo glib ];
  installPhase = ''
    mkdir -p $out/bin $out/share/obinskit
    cp -r * $out/share/obinskit
    makeWrapper $out/share/obinskit/obinskit $out/bin/obinskit \
      --chdir $out/share/obinskit \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib libxkbcommon (lib.getLib systemd) libxt libxtst ]}"
  '';
  meta.platforms = lib.platforms.x86;
}

