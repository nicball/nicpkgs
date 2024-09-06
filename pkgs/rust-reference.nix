{ stdenv, fetchFromGitHub, mdbook-epub }:

stdenv.mkDerivation {
  pname = "rust-reference";
  version = "unstable-2024-08-30";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "reference";
    rev = "df36291f495153180e01b78397997761797d583a";
    sha256 = "sha256-0v0nL6npcdYN9/1OIP94wJw5w0aZzK9NUPk+ZED5Mzc=";
  };
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone true
    mv book $out/
    runHook postInstall
  '';
}
