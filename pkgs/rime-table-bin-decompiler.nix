{ lib, stdenv, boost188, cmake }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.rime-table-bin-decompiler; in

stdenv.mkDerivation {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
  nativeBuildInputs = [ cmake boost188 ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./rime-table-decompiler $out/bin
    runHook postInstall
  '';
}
