{ fetchFromGitHub
, stdenv
, mdbook-epub
}:

stdenv.mkDerivation {
  pname = "rust-async-book";
  version = "unstable-2023-07-06";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "async-book";
    rev = "1ef20c71ba1a365a3b09092b5fef27fe23e45de3";
    sha256 = "sha256-RFsu8+Y2LrueXfTKJOrD2Pyy5Aoa/ap0eKBP+CBdeVM=";
  };
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone true
    mv book/epub/*.epub $out/
    runHook postInstall
  '';
}
