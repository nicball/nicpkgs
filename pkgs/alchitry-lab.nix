{ lib, stdenv, fetchurl, makeWrapper, jre }:

stdenv.mkDerivation {
  pname = "alchitry-lab";
  version = "1.2.7";
  src = fetchurl {
    url = "https://cdn.alchitry.com/labs/alchitry-labs-1.2.7-linux.tgz";
    sha256 = "sha256-LQOVa99DIQHyD6+o/vEeiC8zpx4RCkJTw/P5Gh9mZT0=";
  };
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/alchitry-lab}
    DATA=$out/share/alchitry-lab
    cp -r lib library $DATA/

    makeWrapper ${jre}/bin/java $out/bin/alchitry-lab \
      --prefix LD_LIBRARY_PATH : $DATA/lib \
      --add-flags "-cp \"$DATA/lib/*\" com.alchitry.labs.MainKt lin64" \
      --chdir $DATA

    makeWrapper ${jre}/bin/java $out/bin/alchitry-loader \
      --prefix LD_LIBRARY_PATH : $DATA/lib \
      --add-flags "-cp \"$DATA/lib/*\" com.alchitry.labs.MainKt lin64 --loader" \
      --chdir $DATA

    runHook postInstall
  '';
}
