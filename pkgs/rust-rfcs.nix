{ stdenv, mdbook-epub, python3, writeShellScriptBin }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.rust-rfcs; in

stdenv.mkDerivation {
  inherit (nv) pname src;
  version = "unstable-${nv.date}";
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

