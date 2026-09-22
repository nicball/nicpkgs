{ lib, stdenv, fetchzip, writeText
, makeWrapper , wrapGAppsHook3, autoPatchelfHook
, nss, nspr, alsa-lib, libdrm, mesa, systemd, cairo, pango, glib
, libxkbcommon, libxt, libxtst }:

let desktop-file = writeText "hexcore-link.desktop" ''
  [Desktop Entry]
  Name=Hexcore Link
  Exec=@exec@
  Icon=hexcore-link
  Terminal=false
  Type=Application
  Categories=Utility;
  StartupWMClass=hexcore-link
''; in


stdenv.mkDerivation {
  pname = "hexcore-link";
  version = "v2.5.9";
  src = fetchzip {
    url = "https://www.hexcore.xyz/releases/software/hexcore-link/linux/tar/HexcoreLink_2.5.9_x64.tar.gz";
    sha256 = "sha256-9uXbdT1foohz/efMmGOizEO5oC/3S77YJ9uZcSMB9GI=";
  };
  nativeBuildInputs = [ makeWrapper wrapGAppsHook3 autoPatchelfHook ];
  buildInputs = [ nss nspr alsa-lib libdrm mesa pango cairo glib ];
  installPhase = ''
    mkdir -p $out/bin $out/share/{hexcore-link,applications,icons/hicolor/32x32/apps}
    cp -r * $out/share/hexcore-link
    cp resources/icons/tray-darwin@2x.png $out/share/icons/hicolor/32x32/apps/hexcore-link.png
    makeWrapper $out/share/hexcore-link/hexcore-link $out/bin/hexcore-link \
      --chdir $out/share/hexcore-link \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ stdenv.cc.cc.lib libxkbcommon (lib.getLib systemd) libxt libxtst ]}"
    substitute ${desktop-file} $out/share/applications/hexcore-link.desktop \
      --replace-fail "@exec@" "$out/bin/hexcore-link"
  '';
  meta.platforms = lib.platforms.x86;
}
