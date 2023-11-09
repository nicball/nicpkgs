{ fetchzip, stdenv, makeWrapper, jre_headless }:

stdenv.mkDerivation {
  pname = "mirai-console-loader";
  version = "2.1.2";
  src = fetchzip {
    url = "https://github.com/iTXTech/mirai-console-loader/releases/download/v2.1.2/mcl-2.1.2.zip";
    sha256 = "0l2bn5zqps15jscb0j3i844dk7qn71plv3486ayzdb8spfnkigjr";
    stripRoot = false;
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall
    makeWrapper ${jre_headless}/bin/java $out/bin/mcl \
      --add-flags "-jar $src/mcl.jar"
    runHook postInstall
  '';
}
