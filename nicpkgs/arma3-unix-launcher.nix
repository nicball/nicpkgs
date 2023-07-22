{ lib, fetchurl, stdenv, makeWrapper, appimage-run }:

let aulimg = fetchurl {
  url = "https://github.com/muttleyxd/arma3-unix-launcher/releases/download/commit-355/Arma_3_Unix_Launcher-x86_64.AppImage";
  hash = "sha256-Q82d1aBqufJErSTudvBUe4rxThrNE4Xydd7YrG9HcaU=";
}; in

stdenv.mkDerivation {
  pname = "arma3-unix-launcher";
  version = "6.6.6";
  nativeBuildInputs = [ makeWrapper ];
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/arma3-unix-launcher
    cp ${aulimg} $out/share/arma3-unix-launcher/launcher.AppImage
    makeWrapper ${appimage-run}/bin/appimage-run $out/bin/arma3-unix-launcher --add-flags "$out/share/arma3-unix-launcher/launcher.AppImage"
    runHook postInstall
  '';
  meta.platforms = lib.platforms.x86;
}
