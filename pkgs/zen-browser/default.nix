{ lib
, symlinkJoin
, makeWrapper
, stdenv
, fetchzip
, autoPatchelfHook
, nss_latest
, alsa-lib
, libGL
, libva
, pciutils
, wrapGAppsHook3
, glib
, gtk3
, hunspellDicts
, hyphenDicts
, hunspellAttrs ? [ "en_US" ]
, hyphenAttrs ? [ "en-us" ]
}:

let
  hunspell = symlinkJoin {
    name = "zen-browser-hunspell";
    paths = builtins.map (l: hunspellDicts.${l}) hunspellAttrs;
  };
  hyphen = symlinkJoin {
    name = "zen-browser-hyphen";
    paths = builtins.map (l: hyphenDicts.${l}) hyphenAttrs;
  };
  runtimeDeps = lib.makeLibraryPath [ libGL pciutils libva ];
in

stdenv.mkDerivation rec {
  pname = "zen-browser";
  version = "1.0.1-a.19";
  src = fetchzip {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
    sha256 = "sha256-WGaRfsiewSEKK0RC5OMGp7zUbJBy2j1IPUl55XzA9rw=";
  };
  nariveBuildInputs = [ makeWrapper ];
  buildInputs = [ autoPatchelfHook wrapGAppsHook3 glib gtk3 alsa-lib ];
  installPhase = ''
    mkdir -p $out/{bin,share/{applications,${pname}}}
    cp -r * $out/share/${pname}
    makeWrapper $out/share/${pname}/zen-bin $out/bin/zen \
      --prefix LD_LIBRARY_PATH : ${runtimeDeps}
    substitute ${./zen-alpha.desktop} $out/share/applications/zen-alpha.desktop \
      --replace-fail zen $out/bin/zen-bin
    for i in 16x16 32x32 48x48 64x64 128x128; do
      install -d $out/share/icons/hicolor/$i/apps/
      ln -s $out/share/${pname}/browser/chrome/icons/default/default''${i/x*}.png \
        $out/share/icons/hicolor/$i/apps/${pname}.png
    done
    ln -Ts ${hunspell}/share/hunspell $out/share/${pname}/dictionaries
    ln -Ts ${hyphen}/share/hyphen $out/share/${pname}/hyphenation
    cd ${nss_latest}/lib
    for i in *.so; do
      if [ -e $out/share/${pname}/$i ]; then
        ln -sf ${nss_latest}/lib/$i $out/share/${pname}/
      fi
    done
  '';
  meta = {
    platforms = lib.platforms.x86_64;
    mainProgram = "zen";
  };
}
