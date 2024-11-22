{ lib
, symlinkJoin
, stdenv
, fetchzip
, autoPatchelfHook
, nss
, alsa-lib
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
in

stdenv.mkDerivation rec {
  pname = "zen-browser";
  version = "1.0.1-a.19";
  src = fetchzip {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
    sha256 = "sha256-WGaRfsiewSEKK0RC5OMGp7zUbJBy2j1IPUl55XzA9rw=";
  };
  buildInputs = [ autoPatchelfHook wrapGAppsHook3 glib gtk3 nss alsa-lib ];
  installPhase = ''
    mkdir -p $out/{bin,share/{applications,${pname}}}
    cp -r * $out/share/${pname}
    ln -s $out/share/${pname}/zen-bin $out/bin/zen
    substitute ${./zen-alpha.desktop} $out/share/applications/zen-alpha.desktop \
      --replace-fail zen $out/bin/zen-bin
    for i in 16x16 32x32 48x48 64x64 128x128; do
      install -d $out/share/icons/hicolor/$i/apps/
      ln -s $out/share/${pname}/browser/chrome/icons/default/default''${i/x*}.png \
        $out/share/icons/hicolor/$i/apps/${pname}.png
    done
    ln -Ts ${hunspell}/share/hunspell $out/share/${pname}/dictionaries
    ln -Ts ${hyphen}/share/hyphen $out/share/${pname}/hyphenation
    ln -sf ${nss}/lib/libnssckbi.so $out/share/${pname}/
  '';
  meta.platforms = lib.platforms.x86_64;
}
