{ stdenv
, fetchzip
, python3
, makeWrapper
, wrapGAppsHook3
, gobject-introspection
, libnotify
, libappindicator-gtk3
, webkitgtk
, xorg
, alsa-lib
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "nutstore-client";
  version = "6.3.6";
  src = fetchzip {
    url = "https://pkg-cdn.jianguoyun.com/static/exe/st/${version}/nutstore_client-${version}-linux-x86_64-public.tar.gz";
    sha256 = "sha256-PgRCIk6CEb3mycRjv+EXouhsufMp/LKRnqYIvJ2qEqM=";
    stripRoot = false;
  };
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    wrapGAppsHook3
    gobject-introspection
    libnotify
    libappindicator-gtk3
    webkitgtk

    (python3.withPackages (p: with p; [ pygobject3 ]))

    autoPatchelfHook
    xorg.libXtst
    alsa-lib
  ];
  buildPhase = ''
    substituteInPlace gnome-config/menu/nutstore-menu.desktop \
      --replace-fail '~/.nutstore/dist/bin/nutstore-pydaemon.py' $out/bin/nutstore
    substituteInPlace gnome-config/autostart/nutstore-daemon.desktop \
      --replace-fail '~/.nutstore/dist' $out/share/nutstore
    cd bin
    substituteInPlace nutstore-pydaemon.py \
      --replace-fail gvfs-set-attribute "gio set"
    python -m compileall .
    cd ..
  '';
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp -aR . $out/share/nutstore
    makeWrapper $out/share/nutstore/bin/nutstore-pydaemon.py $out/bin/nutstore
    install -D -m644 gnome-config/menu/nutstore-menu.desktop $out/share/applications/nutstore.desktop
    install -D -m644 app-icon/nutstore.png $out/share/icons/hicolor/512x512/apps/nutstore.png
  '';
}