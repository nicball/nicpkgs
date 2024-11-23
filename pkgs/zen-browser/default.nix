{ lib
, symlinkJoin
, stdenv
, fetchzip
, wrapFirefox
, autoPatchelfHook
, nss_latest
, nspr
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
  unwrapped =
    stdenv.mkDerivation rec {
      pname = "zen-browser";
      version = "1.0.1-a.19";
      src = fetchzip {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-specific.tar.bz2";
        sha256 = "sha256-WGaRfsiewSEKK0RC5OMGp7zUbJBy2j1IPUl55XzA9rw=";
      };
      nativeBuildInputs = [ wrapGAppsHook3 autoPatchelfHook ];
      buildInputs = [ glib gtk3 alsa-lib ];
      installPhase = ''
        mkdir -p $out/{bin,share/applications,lib/${pname}}
        cp -r * $out/lib/${pname}
        ln -s $out/lib/${pname}/zen-bin $out/bin/zen
        ln -Ts ${hunspell}/share/hunspell $out/lib/${pname}/dictionaries
        ln -Ts ${hyphen}/share/hyphen $out/lib/${pname}/hyphenation
        for lib in ${nss_latest} ${nspr}; do
          cd $lib/lib
          for i in *.so; do
            if [ -e $out/lib/${pname}/$i ]; then
              ln -sf $lib/lib/$i $out/lib/${pname}/
            fi
          done
        done
      '';
      meta = {
        platforms = lib.platforms.x86_64;
        mainProgram = "zen";
        description = "Guess what it is.";
      };
      passthru = {
        alsaSupport = true;
        binaryName = "zen";
        requireSigning = true;
        allowAddonSideload = false;
        jackSupport = true;
        pipewireSupport = true;
        sndioSupport = true;
        inherit nspr gtk3;
        ffmpegSupport = true;
        gssSupport = true;
      };
    };
  package = wrapFirefox unwrapped {
    pname = "zen-browser";
    libName = "zen-browser";
  };
in

package.overrideAttrs (self: super: {
  buildCommand = super.buildCommand + "\n" + ''
    rm $out/share/applications/zen.desktop
    substitute ${./zen-alpha.desktop} $out/share/applications/zen-alpha.desktop \
      --replace-fail @zen@ $out/bin/zen
  '';
})
