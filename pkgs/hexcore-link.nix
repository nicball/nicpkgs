{ lib, stdenv, fetchzip
, makeWrapper , wrapGAppsHook3, autoPatchelfHook
, nss, nspr, alsa-lib, libdrm, mesa, systemd, cairo, pango, glib }:

stdenv.mkDerivation {
  pname = "hexcore-link";
  version = "v2.5.9";
  src = fetchzip {
    url = "https://s5.hexcore.xyz/releases/software/hexcore-link/linux/tar/HexcoreLink_2.5.9_x64.tar.gz";
    sha256 = "sha256-9uXbdT1foohz/efMmGOizEO5oC/3S77YJ9uZcSMB9GI=";
  };
  nativeBuildInputs = [ makeWrapper wrapGAppsHook3 autoPatchelfHook ];
  buildInputs = [ nss nspr alsa-lib libdrm mesa pango cairo glib ];
  installPhase = ''
    mkdir -p $out/bin $out/share/hexcore-link
    cp -r * $out/share/hexcore-link
    makeWrapper $out/share/hexcore-link/hexcore-link $out/bin/hexcore-link \
      --chdir $out/share/hexcore-link \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ systemd ]}
  '';
  meta.platforms = lib.platforms.x86;
}
