{ stdenv, fetchFromGitHub, mdbook-epub }:

stdenv.mkDerivation {
  pname = "rust-reference";
  version = "unstable-2022-12-04";
  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "reference";
    rev = "3ae62681ff236d5528ef7c8c28ba7c6b2ecc6731";
    sha256 = "sha256-EEEa0uxmMXzYTo753eVAYUXekztbkR5CL5eK4XytOU8=";
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
