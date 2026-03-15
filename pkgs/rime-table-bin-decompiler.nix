{ nv-sources, lib, stdenv, boost188, cmake }:

stdenv.mkDerivation {
  inherit (nv-sources.rime-table-bin-decompiler) pname src;
  version = "unstable-${nv-sources.rime-table-bin-decompiler.date}";
  nativeBuildInputs = [ cmake boost188 ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./rime-table-decompiler $out/bin
    runHook postInstall
  '';
}
