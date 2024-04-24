{ stdenv, fetchFromGitHub, mdbook-epub, python3, writeShellScriptBin }:

stdenv.mkDerivation {
  pname = "rust-rfcs";
  version = "unstable-2024-04-24";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rfcs";
    rev = "fab408e9bc960a93c1719b8ce9931454f94dfde6";
    sha256 = "sha256-sUEV5lGk3XbUKQawKlvnn1CrU2OHAYroXhBkrhRFCfg=";
  };
  dontConfigure = true;
  buildPhase = ''
    runHook preBuild
    ${python3}/bin/python generate-book.py || true
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    ${mdbook-epub}/bin/mdbook-epub --standalone true
    mkdir $out
    mv book $out/
    runHook postInstall
  '';
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "sha256-LDfMNiks6muU3Vb7zsQtNuCIiMrM5ldlet5W8bqNJHo=";
  meta.broken = true;
}

