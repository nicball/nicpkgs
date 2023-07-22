{ lib, stdenv, fetchurl, unzip, makeWrapper, mono }:

stdenv.mkDerivation rec {
  pname = "terraria-server";
  version = "1.4.3.6";
  urlVersion = lib.replaceChars [ "." ] [ "" ] version;
  src = fetchurl {
    url = "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${urlVersion}.zip";
    sha256 = "sha256-OFI7U6Mqu09pIbgJQs0O+GS8jf1uVuhAVEJhYNYXrBE=";
  };
  nativeBuildInputs = [ unzip makeWrapper ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    rm Linux/System*
    rm Linux/Mono*
    rm Linux/monoconfig
    rm Linux/mscorlib.dll
    mkdir -p $out/share/Terraria
    cp -r Linux $out/share/Terraria/
    makeWrapper ${mono}/bin/mono $out/bin/terraria-server --argv0 terraria-server --add-flags "--server --gc=sgen -O=all $out/share/Terraria/Linux/TerrariaServer.exe"
    runHook postInstall
  '';
}
