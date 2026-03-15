{ stdenv, nv-sources, mdbook-epub }:

stdenv.mkDerivation {
  inherit (nv-sources.rust-reference) pname src;
  version = "unstable-${nv-sources.rust-reference.date}";
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone
    mv book/* $out/
    runHook postInstall
  '';
}
