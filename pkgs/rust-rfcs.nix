{ stdenv, nv-sources, mdbook-epub, python3, writeShellScriptBin }:

stdenv.mkDerivation {
  inherit (nv-sources.rust-rfcs) pname src;
  version = "unstable-${nv-sources.rust-rfcs.date}";
  dontConfigure = true;
  buildPhase = ''
    runHook preBuild
    ${python3}/bin/python generate-book.py || true
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    ${mdbook-epub}/bin/mdbook-epub --standalone
    mkdir $out
    mv book $out/
    runHook postInstall
  '';
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  meta.broken = true;
}

