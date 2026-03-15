{ nv-sources
, stdenv
, mdbook-epub
}:

stdenv.mkDerivation {
  inherit (nv-sources.rust-async-book) pname src;
  version = "unstable-${nv-sources.rust-async-book.date}";
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone
    mv book/epub/*.epub $out/
    runHook postInstall
  '';
}
