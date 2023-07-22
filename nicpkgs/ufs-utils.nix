{ stdenv, fetchFromGitHub, glibc }:

stdenv.mkDerivation {
  pname = "ufs-utils";
  version = "v4.13.5";
  src = fetchFromGitHub {
    owner = "westerndigitalcorporation";
    repo = "ufs-utils";
    rev = "18c0a8454ca1cf8969170049f8c628d88627beec";
    sha256 = "sha256-oZV4qNbLoZIWbw2Riig4r6ZEkE6+ED2tuvWXVizHmbE=";
  };
  nativeBuildInputs = [ glibc.static ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ufs-utils $out/bin
    runHook postInstall
  '';
}
