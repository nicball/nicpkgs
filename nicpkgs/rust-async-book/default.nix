{ fetchFromGitHub
, stdenv
, mdbook
, mdbook-epub
}:

stdenv.mkDerivation {
  pname = "rust-async-book";
  version = "6.6.6";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "async-book";
    rev = "e224ead5275545acc00fa82d94ba6d6f377c8563";
    sha256 = "sha256-lzUljczQ7hPZAVi+bFXth0sDTX+C/W1f/iBiK3gPtO0=";
  };
  dontConfigure = true;
  dontBuild = true;
  patches = [ ./rust-async-book.patch ];
  nativeBuildInputs = [ mdbook mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook build
    mv book $out/
    runHook postInstall
  '';
}
