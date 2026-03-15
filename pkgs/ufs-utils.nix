{ stdenv, nv-sources, glibc }:

stdenv.mkDerivation {
  inherit (nv-sources.ufs-utils) pname version src;
  nativeBuildInputs = [ glibc.static ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ufs-utils $out/bin
    runHook postInstall
  '';
}
