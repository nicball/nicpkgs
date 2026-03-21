{ nv-sources
, stdenv
, mdbook-epub
}:

stdenv.mkDerivation {
  inherit (nv-sources.rust-book) pname src version;
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

