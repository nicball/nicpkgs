{ stdenv, glibc }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.ufs-utils; in

stdenv.mkDerivation {
  inherit (nv) pname version src;
  nativeBuildInputs = [ glibc.static ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ufs-utils $out/bin
    runHook postInstall
  '';
}
