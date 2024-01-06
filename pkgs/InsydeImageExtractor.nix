{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation {
  pname = "InsydeImageExtractor";
  version = "0.1.0";
  src = fetchFromGitHub {
    owner = "LongSoft";
    repo = "InsydeImageExtractor";
    rev = "d09a6b1e2cbe8b4f95f6962dba79ae9d6744e199";
    sha256 = "sha256-a/J6SHokRS4DEE/3bkch2/uW4Z86sx26xhg2qMoyJPk=";
  };
  nativeBuildInputs = [ cmake ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp extractor $out/bin/
    runHook postInstall
  '';
}

