{ stdenv, nv-sources, mdbook-epub }:

stdenv.mkDerivation {
  inherit (nv-sources.wayland-book) pname src;
  version = "unstable-${nv-sources.wayland-book.date}";
  patches = [ ./ccpng.patch ];
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone
    mv book/*.epub $out/
    runHook postInstall
  '';
}
